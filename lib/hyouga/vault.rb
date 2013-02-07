module Hyouga
	class Vault
		def initialize(wrapper, vault_name)
			@wrapper = Wrapper.new(wrapper, vault_name: vault_name)
		end

		def new_upload(parts, descr)
			upload = MultipartUpload.new(@wrapper, parts.part_size, descr)
			Uploader.new(upload, parts)
		end
	end
end
