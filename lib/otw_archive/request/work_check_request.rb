module OtwArchive
  module Request
    class WorkCheckRequest
      def initialize(original_urls = [])
        @original_urls = original_urls.each do |id, url|
          {
            id: id,
            url: url
          }
        end
      end
    end
  end # Request
end # OtwArchive

