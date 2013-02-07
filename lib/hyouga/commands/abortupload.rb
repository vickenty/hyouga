module Hyouga::Commands
	class AbortUpload < Base
		NAME = "abort-upload"
		ARGS = "<vault> <upload_id>"
		DOC = "abort multipart upload"
		LONG_DESC = "Abort a multipart upload to the given vault."

		def execute
			opts = parse_options do
				stop_on_unknown
			end

			vault_name = @args.shift
			Trollop::die "missing vault" if vault_name.nil?

			upload_id = @args.shift
			Trollop::die "missing upload_id" if upload_id.nil?

			wrapper.abort_multipart_upload(vault_name: vault_name, upload_id: upload_id)
		end
	end
end
