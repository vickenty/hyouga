module Hyouga::Commands
	class GetJob < Base
		NAME = "get-job"
		DOC = "get job output"
		ARGS = "<vault> <job_id>"
		LONG_DESC = "Get job output and puts it to standard output."

		def execute
			opts = parse_options do
				stop_on_unknown
			end

			vault_name = shift_arg("vault")
			job_id = shift_arg("job_id")

			resp = wrapper.get_job_output(
				vault_name: vault_name,
				job_id: job_id
			)

			puts resp[:body]
		end
	end
end
