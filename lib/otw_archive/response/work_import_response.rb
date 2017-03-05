module OtwArchive
  module Response
    class WorkImportResponse
      def initialize(status, url, original_id, original_url, messages)
        @status = status
        @work_url = url
        @original_id = original_id
        @original_url = original_url
        @messages = messages
      end
    end
  end # Response
end # OtwArchive
