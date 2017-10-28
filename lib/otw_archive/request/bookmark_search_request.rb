module OtwArchive
  module Request
    class BookmarkSearchRequest
      def initialize(archivist, bookmarks = [])
        @archivist = archivist
        @bookmarks = bookmarks
      end
    end
  end # Request
end # OtwArchive

