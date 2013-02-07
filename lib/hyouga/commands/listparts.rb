module Hyouga::Commands
	class ListParts < Base
		NAME = "list-parts"
		DOC = "list upload parts and their hashes"
		ARGS = "<filename>"
		LONG_DESC = "List upload parts in a file, along with hashes."

		def execute
			opts = parse_options do
				opt :part_size, "Set part size in MB (default: autodetect)", type: :integer, default: nil
				stop_on_unknown
			end

			filename = @args.shift
			Trollop::die "Please specify a filename." if filename.nil?

			opts[:part_size] *= 2**20 unless opts[:part_size].nil?

			stream = File.open(filename, "rb")
			parts = Hyouga::PartStream.new(stream, opts[:part_size])

			parts.each_part do |part|
				puts "#{part.linear_hash} #{part.tree_hash} #{part.size} @#{part.start}"
			end

			puts "-"*79

			puts "#{parts.linear_hash} #{parts.tree_hash} #{parts.size}"
		end
	end
end
