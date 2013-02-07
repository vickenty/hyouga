require 'trollop'
require 'hyouga'
require 'hyouga/reporter'
require 'hyouga/command'

Dir.glob(File.expand_path("../commands/*.rb", __FILE__)).each { |file| require file }

module Hyouga
	class Main
		def initialize(args)
			@command = nil
			@args = args

			@available = {}
			Commands.constants.each do |sym|
				const = Commands.const_get(sym)
				name = const.const_get(:NAME)
				@available[name] = const unless name.nil?
			end
		end

		def execute
			parse_opts
			fail if @command.nil?
			@command.execute
		end

		def parse_opts
			commands_list = @available.keys
			commands = commands_list.join(" ")
			commands_help = build_cmd_help

			opts = Trollop::options do
				banner "#{$0} [options] <command> ..."
				banner ""
				banner "Commands:"
				commands_help.each { |line| banner(line) }
				banner ""
				banner "Options:"
				opt :account, "AWS account ID", default: "-", short: "-a"
				stop_on commands_list
			end

			Trollop::die "missing command" if @args.empty?

			glacier = AWS::Glacier.new
			wrapper = Hyouga::Wrapper.new(glacier.client, account_id: opts[:account])

			cmd = @args.shift
			impl = @available[cmd]
			Trollop::die "unknown command #{cmd}" if impl.nil?

			@command = impl.new(wrapper, @args)
		end

		def build_cmd_help
			max_cmd_len = @available.keys.map { |cmd| cmd.length }.max
			@available.sort.map do |cmd, impl|
				help = impl.const_get(:DOC)

				line = [
					" " * (max_cmd_len - cmd.length + 2),
					cmd,
					":   ",
					help
				]

				line.join("")
			end
		end
	end
end
