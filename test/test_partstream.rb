require 'test/unit'
require 'stringio'
require 'hyouga'

class HashFileTest < Test::Unit::TestCase
	def test_simple_file
		part_size = Hyouga::PartStream::CHUNK_SIZE
		full_size = 2 * part_size
		full_hash = '560c2c9333c719cb00cfdffee3ba293db17f58743cdd1f7e4055373ae6300afa'
		part_hash = '9bc1b2a288b26af7257a36277ae3816a7d4f16e89c1e7e77d0a5c48bad62b360'

		stream = StringIO.new("a" * full_size)
		file = Hyouga::PartStream.new(stream, part_size)
		file.each_part do |part|
			assert_equal part_hash, part.tree_hash
			assert_equal part_size, part.size

			data = part.stream.read
			assert_equal part_size, data.length
			assert_equal part_hash, Digest::SHA256.new.hexdigest(data)
		end

		assert_equal full_hash, file.tree_hash
	end
end
