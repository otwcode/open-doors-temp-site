module OtwArchive
  class ImportConfig

    attr_reader :archive_host, :token, :archivist, :post_without_preview, :restricted, :override_tags, :detect_tags,
                :send_claim_emails, :encoding

    def initialize(archive_host, token, archivist, post_without_preview = true, restricted = true,
                   override_tags = true, detect_tags = false, send_claim_emails = false, encoding = "UTF-8")
      @archive_host = archive_host
      @token = token
      @archivist = archivist
      @post_without_preview = post_without_preview
      @restricted = restricted
      @override_tags = override_tags
      @detect_tags = detect_tags
      @send_claim_emails = send_claim_emails
      @encoding = encoding
    end
  end
end # OtwArchive
