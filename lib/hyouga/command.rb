module Hyouga::Commands
	class Base
		NAME = nil
		DOC = ''
		LONG_DESC = ''
		ARGS = ''

		attr_reader :wrapper

		def initialize(wrapper, args)
			@wrapper = wrapper
			@args = args
		end

		def parse_options(&block)
			name = self.class.const_get(:NAME)
			args = self.class.const_get(:ARGS)
			desc = self.class.const_get(:LONG_DESC)
			Trollop::options(@args) do
				banner "#{$0} #{name} [options] #{args}"
				banner ""
				banner desc
				banner ""
				banner "Options:"
				instance_eval(&block)
			end
		end

		def shift_arg(name, required=true)
			val = @args.shift
			Trollop::die("Missing required argument: #{name}") if val.nil? and required
			val
		end
	end
end
