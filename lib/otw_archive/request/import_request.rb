module OtwArchive
  module Request
    class ImportRequest
      attr_reader :archivist, :detect_tags, :encoding, :collection_name,
                  :works, :bookmarks

      def initialize(archivist, send_email, post_preview, detect_tags, encoding, works, bookmarks)
        @archivist = archivist
        @send_claim_emails = send_email
        @post_without_preview = post_preview
        @detect_tags = detect_tags
        @encoding = encoding
        @works = works
        @bookmarks = bookmarks
      end

      def self.populate_from_config(config, works, bookmarks)
        new(
          config.archive_config.archivist,
          config.archive_config.send_email,
          config.archive_config.post_preview,
          config.detect_tags,
          config.encoding,
          works,
          bookmarks
        )
      end
    end
  end # Request
end # OtwArchive
