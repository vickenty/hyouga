module Hyouga
	class Vault
		def initialize(wrapper, vault_name)
			@wrapper = Wrapper.new(wrapper, vault_name: vault_name)
		end

		def new_upload(stream, part_size, descr)
			upload = MultipartUpload.new(@wrapper, part_size, descr)
			Uploader.new(upload, stream)
		end

		def resume_upload(stream, upload_id)
			upload = MultipartUpload.resume(@wrapper, upload_id)
			Uploader.new(upload, stream)
		end
	end
end
