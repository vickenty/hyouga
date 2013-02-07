require 'ruby-progressbar'

module Hyouga
	class Reporter
		FORMAT = "%a [%b>%i] %p%% %c/%C %e"

		def initialize(uploader)
			@uploader = uploader
			@stream = uploader.partstream
			@running = nil
			@thread = nil
			@progress = ProgressBar.create(
				format: FORMAT,
				total: @stream.size
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
			unless part.nil?
				@progress.progress = part.nil? ? 0 : part.stream.offset
				if part.stream.offset == @stream.size
					@running = false
				end
			end
		end
	end
end
