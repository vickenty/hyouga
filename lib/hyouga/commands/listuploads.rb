module Hyouga::Commands
	class ListUploads < Base
		NAME = "list-uploads"
		DOC = "list active uploads"
		ARGS = "<vault>"
		LONG_DESC = "List active multipart uploads to the vault."

		def execute
			opts = parse_options do
				stop_on_unknown
			end

			vault_name = @args.shift
			Trollop::die "missing vault name" if vault_name.nil?

			resp = wrapper.list_multipart_uploads(vault_name: vault_name)
			uploads = resp[:uploads_list]

			uploads.each do |upload|
				show upload
			end
		end

		def show upload
			puts "#{upload[:multipart_upload_id]}\t#{upload[:creation_date]}\t#{upload[:archive_description] or "<no description>"}"
		end
	end
end
