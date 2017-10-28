module OtwArchive
  module Request
    class WorkSearchRequest
      def initialize(original_urls = [])
        @works = original_urls.each do |id, url|
          {
            original_urls: {
              id: id,
              url: url
            }
          }
        end
      end
    end
  end # Request
end # OtwArchive

