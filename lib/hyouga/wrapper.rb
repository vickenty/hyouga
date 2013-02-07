module Hyouga
	class Wrapper
		def initialize(client, defaults={})
			@client = client
			@defaults = defaults
		end

		def method_missing(symbol, *args)
			args << @defaults.merge(args.pop || {})
			@client.send(symbol, *args)
		end
	end
end
