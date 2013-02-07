module Hyouga::Commands
	class ListVaults < Base
		NAME = "list-vaults"
		DOC = "list vaults"
		ARGS = "[pattern] ..."
		LONG_DESC = "List vaults that match one of the patterns. If no patterns specified, list all vaults."

		def execute
			opts = parse_options do
				opt :verbose, "Display more details", short: '-v'
				stop_on_unknown
			end

			resp = wrapper.list_vaults

			@verbose = opts[:verbose]

			@args << "*" if @args.empty?

			resp[:vault_list].each do |vault|
				@args.each do |glob|
					if File.fnmatch(glob, vault[:vault_name])
						show vault
						break
					end
				end
			end
		end

		def show(vault)
			if @verbose
				show_verbose(vault)
			else
				show_terse(vault)
			end
		end

		def show_terse(vault)
			puts vault[:vault_name]
		end

		def show_verbose(vault)
			puts "#{vault[:vault_name]} created #{vault[:creation_date]}"
			puts "\t#{vault[:number_of_archives]} archives, #{vault[:size_in_bytes]} bytes"
		end
	end
end
