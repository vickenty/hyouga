module Hyouga::Commands
	class Delete < Base
		NAME = "delete"
		DOC = "delete a vault or an archive"
		ARGS = "<vault> [archive_id]"
		LONG_DESC = "Delete an empty vault or an archive."

		def execute
			opts = parse_options do
				stop_on_unknown
			end

			vault_name = shift_arg("vault")
			archive_id = shift_arg("archive_id", false)

			if archive_id.nil?
				wrapper.delete_vault(vault_name: vault_name)
			else
				wrapper.delete_archive(
					vault_name: vault_name,
					archive_id: archive_id
				)
			end
		end
	end
end
