module OtwArchive
  module Response
    class CheckResponse
      def initialize(status, messages, work_responses)
        @status = status
        @messages = messages
        @work_responses = work_responses
      end
    end

    class WorkResponse
      def initialize(status, original_id, original_url, work_url, created)
        @status = status
        @original_id = original_id
        @original_url = original_url
        @work_url = work_url
        @created = created
      end
    end
  end # Response
end # OtwArchive
