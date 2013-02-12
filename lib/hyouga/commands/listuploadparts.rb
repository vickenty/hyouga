module Hyouga::Commands
	class ListUploadParts < Base
		NAME = 'list-upload-parts'
		DOC = "list parts uploaded in a pending upload."
		ARGS = '<vault> <upload_id>'
		LONG_DESC = "List all parts uploaded to a pending upload."

		def execute
			opts = parse_options do
				stop_on_unknown
			end

			vault_name = shift_arg("vault")
			upload_id = shift_arg("upload_id")

			params = { vault_name: vault_name, upload_id: upload_id }

			resp = nil
			begin
				params.merge! marker: resp[:marker] if resp and resp[:marker]
				resp = wrapper.list_parts(params)
				resp[:parts].each do |part|
					puts "#{part[:sha256_tree_hash]} #{part[:range_in_bytes]}"
				end
			end until resp[:marker].nil?
		end
	end
end
