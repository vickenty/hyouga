module Hyouga
	class MultipartUpload
		attr_reader :upload_id, :part_size

		def initialize(wrapper, part_size, descr, upload_id=nil)
			@wrapper = wrapper
			@part_size = part_size
			@descr = descr
			@upload_id = upload_id
			@uploaded = {}
		end

		def self.resume(wrapper, upload_id)
			marker = nil
			info = wrapper.list_parts(upload_id: upload_id)

			upload = new(
				wrapper,
				info[:part_size_in_bytes],
				info[:archive_description],
				upload_id
			)
			upload.fetch_uploaded
			upload
		end

		def fetch_uploaded
			marker = nil
			params = { upload_id: upload_id }
			begin
				params[:marker] = marker if marker
				info = @wrapper.list_parts(params)
				marker = info[:marker]
				parse_uploaded(info[:parts])
			end until marker.nil?
		end

		def parse_uploaded(parts)
			parts.each_with_object(@uploaded) do |part, uploaded|
				first, last = part[:range_in_bytes].split(/-/).map { |v| v.to_i }
				uploaded[first] = part[:sha256_tree_hash]
			end
		end

		def started?
			not @upload_id.nil?
		end

		def start
			upload = @wrapper.initiate_multipart_upload(
				part_size: part_size,
				archive_description: @descr
			)
			@upload_id = upload[:upload_id]
		end

		def upload_part(part)
			return if @uploaded[part.start] == part.tree_hash

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
