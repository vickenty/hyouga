module Hyouga::Commands
	class Create < Base
		NAME = "create"
		DOC = "create new vault"
		ARGS = "<vault>"
		LONG_DESC = "Create new vault."

		def execute
			opts = parse_options do
				stop_on_unknown
			end

			vault_name = shift_arg("vault")
			wrapper.create_vault(vault_name: vault_name)
		end
	end
end
