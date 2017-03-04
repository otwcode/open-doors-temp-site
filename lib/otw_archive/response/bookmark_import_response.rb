module OtwArchive
  module Response
    class BookmarkImportResponse
      def initialize(original_id, status, archive_url, original_url, messages)
        @original_id = original_id
        @status = status
        @archive_url = archive_url
        @original_url = original_url
        @messages = messages
      end
    end
  end # Response
end # OtwArchive
