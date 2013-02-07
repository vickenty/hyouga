module Hyouga::Commands
	class StartJob < Base
		NAME = "start-job"
		DOC = "start a job in the vault"
		ARGS = "<vault> <type> [description]"
		LONG_DESC = "Start a job in the vault."

		def execute
			opts = parse_options do
				stop_on_unknown
			end

			vault_name = shift_arg("vault")
			type = shift_arg("type")
			desc = shift_arg("description", false)

			resp = wrapper.initiate_job(
				vault_name: vault_name,
				job_parameters: {
					format: "JSON",
					type: type,
					description: desc
				}
			)
			puts resp
		end
	end
end
