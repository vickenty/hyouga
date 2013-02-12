require 'ruby-progressbar'

module Hyouga
	class Reporter
		FORMAT = "[%T] %a [%b>%i] %p%% %c/%C %e"

		def initialize(uploader, total)
			@uploader = uploader
			@stream = uploader.partstream
			@running = nil
			@thread = nil
			@total = total
			@progress = ProgressBar.create(
				format: FORMAT,
				total: total
			)
		end

		def start
			@running = true
			@thread = Thread.new(self) { |progress| progress.loop }
		end

		def stop
			return unless @running
			@running = false
			@thread.join
			@progress.finish
		end

		def loop
			while @running
				update
				sleep(0.1)
			end
		end

		def update
			part = @uploader.current_part
			@progress.title = @uploader.state.to_s
			unless part.nil?
				@progress.progress = part.nil? ? 0 : part.stream.offset
				if part.stream.offset == @total
					@running = false
				end
			end
		end
	end
end
