module Hyouga::Commands
	class ListJobs < Base
		NAME = "list-jobs"
		DOC = "list pending jobs"
		ARGS = "<vault>"
		LONG_DESC = "List jobs present in the vault."

		def execute
			opts = parse_options do
				stop_on_unknown
			end

			vault_name = shift_arg("vault")
			resp = wrapper.list_jobs(vault_name: vault_name)

			resp[:job_list].each do |job|
				show job
			end
		end

		def show(job)
			Hyouga::Formatter.print_job(job)
		end
	end
end
