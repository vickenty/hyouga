module Hyouga
	class Formatter
		def self.print_job(job)
			complete = job[:completed] ? "READY" : "     "
			puts "#{complete} #{job[:job_id]} #{job[:job_description] or "<no description>"}"
		end
	end
end
