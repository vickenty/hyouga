module Hyouga
	class Uploader
		attr_reader :partstream, :current_part, :state

		def initialize(upload, partstream)
			@upload = upload
			@partstream = partstream
			@current_part = nil
			@state = :idle
		end

		def upload
			@upload.wrap do |upload|
				@state = :first
				@partstream.each_part do |part|
					@current_part = part
					@state = :upload
					upload.upload_part part
					@state = :next
				end

				@state = :finalize
				@resp = upload.complete(
					@partstream.linear_hash,
					@partstream.tree_hash,
					@partstream.size)
			end
			@state = :done

			@resp[:archive_id]
		end
	end
end
