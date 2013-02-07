module Hyouga
	class Substream
		attr_reader :offset, :size, :last

		def initialize(stream, offset, size)
			@stream = stream
			@offset = offset
			@size = size
			@last = offset + size
		end

		def read(req=nil)
			return nil if eof?

			req = @last - @offset if req.nil? or @offset + req > @last
			@stream.seek(@offset)
			data = @stream.read(req)
			@offset += req

			data
		end

		def eof?
			@offset >= @last
		end

		def close
			@stream.close
		end
	end
end
