require 'test/unit'
require 'stringio'
require 'hyouga'

class SubstreamTest < Test::Unit::TestCase
	def test_substream_parts
		stream = StringIO.new("a" * 2**20)
		sub = Hyouga::Substream.new(stream, 0, 65536)
		buf = []
		until sub.eof?
			data = sub.read(800)
			buf << data
		end

		buf = buf.join("")
		assert_equal 65536, buf.length
	end

	def test_substream_unbound
		stream = StringIO.new("a" * 2**20)
		sub = Hyouga::Substream.new(stream, 0, 65536)
		buf = sub.read
		assert_equal 65536, buf.length
	end
end
