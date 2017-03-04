module OtwArchive
  module Request
    class CheckRequest
      def initialize(original_urls = [])
        @original_urls = original_urls.for_each do |id, url|
          CheckRequestUrl.new(id, url)
        end
      end
    end

    class CheckRequestUrl
      def initialize(id, url)
        @id = id
        @url = url
      end
    end
  end # Request
end # OtwArchive

