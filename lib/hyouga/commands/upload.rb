module Hyouga::Commands
	class Upload < Base
		NAME = "upload"
		DOC = "upload a file to the vault"
		ARGS = "<vault> <filename>"
		LONG_DESC = "Upload a file to the vault."

		def execute
			opts = parse_options do
				opt :part_size, "Set upload part size in MB (default: autodetect)", type: :integer, default: nil
				opt :interactive, "Display progress bar", short: '-i'
				opt :description, "Set archive description", short: '-d', type: :string
				opt :save_name, "Save filename as archive description", short: '-n'
				opt :resume, "Resume an interrupted upload", short: '-r', type: :string
				stop_on_unknown
			end

			vault_name = @args.shift
			Trollop::die "missing vault name" if vault_name.nil?

			filename = @args.shift
			Trollop::die "missing filename" if filename.nil?

			descr = nil
			descr = File.basename(filename) if opts[:save_name]
			descr = opts[:description] unless opts[:description].nil?

			stream = File.open(filename, "rb")
			vault = Hyouga::Vault.new(wrapper, vault_name)

			size = File.size(filename)

			if opts[:part_size].nil?
				part_size = Hyouga::PartStream.detect_part_size(size)
			else
				part_size = opts[:part_size] * 2**20
			end

			if opts[:resume].nil?
				uploader = vault.new_upload(stream, part_size, descr)
			else
				uploader = vault.resume_upload(stream, opts[:resume])
			end

			reporter = nil
			if opts[:interactive]
				reporter = Hyouga::Reporter.new(uploader, size)
				reporter.start
			end

			archive_id = uploader.upload

			reporter.stop unless reporter.nil?

			puts archive_id
		end
	end
end
