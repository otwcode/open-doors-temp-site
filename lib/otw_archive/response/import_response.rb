module OtwArchive
  module Response
    class ImportResponse
      def initialize(status, messages, work_responses, bookmark_responses)
        @status = status
        @messages = messages
        @work_responses = work_responses
        @bookmark_responses = bookmark_responses
      end
    end
  end # Response
end # OtwArchive
