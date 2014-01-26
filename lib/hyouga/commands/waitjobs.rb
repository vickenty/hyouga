module Hyouga::Commands
	class WaitJobs < Base
		NAME = "wait-jobs"
		DOC = "wait for jobs and retrieve jobs' outputs"
		ARGS = "<vault> [job_id] [filename]"
		LONG_DESC = "Wait for job completion and save job output to a file"
		WAIT_TIME = 300

		def execute
			opts = parse_options do
				stop_on_unknown
			end

			vault_name = shift_arg("vault")
			job_id = shift_arg("job_id", false)
			filename = shift_arg("filename", false)

			if job_id.nil? or job_id.empty?
				filename = nil
				wait_for_all(vault_name)
			else
				wait_for_job(vault_name, job_id, filename)
			end
		end

		def wait_for_all(vault_name)
			done = Set.new
			while true
				resp = wrapper.list_jobs(vault_name: vault_name)
				if resp[:job_list].empty?
					break
				end

				wait_jobs = 0
				resp[:job_list].each do |job|
					Hyouga::Formatter.print_job job
					if job[:completed]
						save_job(vault_name, job)
					else
						wait_jobs += 1
					end
				end
				break unless wait_jobs > 0

				sleep WAIT_TIME
			end
		end

		def wait_for_job(vault_name, job_id, filename)
			while true
				job = wrapper.describe_job(vault_name: vault_name, job_id: job_id)
				if job[:completed]
					save_job(vault_name, job, filename)
					break
				end

				sleep WAIT_TIME
			end
		end

		def save_job(vault_name, job, filename=nil)
			filename = make_filename(vault_name, job) if filename.nil?

			out = wrapper.get_job_output(vault_name: vault_name, job_id: job[:job_id])

			IO.write(filename, out[:body])
		end

		def make_filename(vault_name, job)
			desc = job[:job_description]
			desc.gsub!(/[^a-z0-9]/i, "_")
			"#{vault_name}-#{desc}-#{job[:job_id]}.json"
		end
	end
end
