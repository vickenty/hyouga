module Hyouga
	class Part
		attr_reader :start, :size, :linear_hash, :tree_hash, :stream

		def initialize(start, size, linear_hash, tree_hash, stream)
			@start = start
			@size = size
			@linear_hash = linear_hash
			@tree_hash = tree_hash
			@stream = stream
		end

		def last
			@start + @size - 1
		end
	end
end
