module OtwArchive
  module Request
    class ImportRequest
      attr_reader :archivist, :send_claim_emails, :post_without_preview, :detect_tags, :encoding,
                  :works, :bookmarks

      def initialize(archivist, send_claim_emails, post_without_preview, detect_tags, encoding, works, bookmarks)
        @archivist = archivist
        @send_claim_emails = send_claim_emails
        @post_without_preview = post_without_preview
        @detect_tags = detect_tags
        @encoding = encoding
        @works = works
        @bookmarks = bookmarks
      end

      def self.populate_from_config(config, works, bookmarks)
        new(
          config.archivist,
          config.send_claim_emails,
          config.post_without_preview,
          config.detect_tags,
          config.encoding,
          works,
          bookmarks
        )
      end
    end
  end # Request
end # OtwArchive
