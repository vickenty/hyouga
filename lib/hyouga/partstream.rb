require 'digest'

module Hyouga
	class PartStream
		CHUNK_SIZE = 2**20

		attr_reader :stream, :offset, :part_size

		def self.open(filename, part_size=nil)
			self.new(File.open(filename, "rb"), part_size)
		end

		def initialize(stream, part_size=nil)
			@stream = stream
			@offset = 0

			@part_size = part_size || self.class.detect_part_size(stream.size)

			@hashes = []
			@linear_digest = new_digest
		end

		def each_part(&part)
			until stream.eof?
				yield process_next_part
			end
		end

		def linear_hash
			@linear_digest.hexdigest
		end

		def tree_hash
			reduce_tree_hash(@hashes)
		end

		def size
			@stream.size
		end


		def self.detect_part_size(size)
			estimate = size / 1000
			return CHUNK_SIZE if estimate < CHUNK_SIZE
			estimate -= 1
			(0..5).each do |shift|
				estimate |= estimate >> (2 ** shift)
			end
			estimate + 1
		end

		private

		def process_next_part
			remains = part_size

			part_digest = new_digest
			part_hashes = []

			part_start = @offset

			stream.seek(@offset)
			while remains > 0 and !@stream.eof?
				data = @stream.read(CHUNK_SIZE)
				remains -= data.length

				part_digest.update(data)
				@linear_digest.update(data)

				hash = calc_hash(data)
				@hashes << hash
				part_hashes << hash
			end
			total_bytes = part_size - remains
			@offset += total_bytes

			substream = Substream.new(@stream, part_start, total_bytes)

			return Part.new(
				part_start,
				total_bytes,
				part_digest.hexdigest,
				reduce_tree_hash(part_hashes),
				substream)
		end

		def new_digest
			Digest::SHA256.new
		end

		def calc_hash(data)
			new_digest.update(data).digest
		end

		def reduce_tree_hash(hashes)
			while hashes.length > 1
				hashes = hashes.each_slice(2).map do |a, b|
					if b
						calc_hash(a + b)
					else
						a
					end
				end
			end
			Digest.hexencode(hashes.first)
		end
	end
end
