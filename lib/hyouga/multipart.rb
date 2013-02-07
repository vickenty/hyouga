module Hyouga
	class MultipartUpload
		attr_reader :upload_id

		def initialize(wrapper, part_size, descr)
			@wrapper = wrapper
			@part_size = part_size
			@descr = descr
			@upload_id = nil
		end

		def wrap(&block)
			begin
				start
				yield self
			rescue
				cancel
				raise
			end
		end

		def start
			upload = @wrapper.initiate_multipart_upload(
				part_size: @part_size,
				archive_description: @descr
			)
			@upload_id = upload[:upload_id]
		end

		def upload_part(part)
			@wrapper.upload_multipart_part(
				upload_id: upload_id,
				checksum: part.tree_hash,
				content_sha256: part.linear_hash,
				range: "bytes #{part.start}-#{part.last}/*",
				body: part.stream
			)
		end

		def complete(linear_hash, tree_hash, size)
			@wrapper.complete_multipart_upload(
				upload_id: upload_id,
				checksum: tree_hash,
				archive_size: size
			)
		end

		def cancel
			@wrapper.abort_multipart_upload(upload_id: upload_id) unless upload_id.nil?
		end
	end
end
