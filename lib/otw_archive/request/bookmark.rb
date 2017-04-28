module OtwArchive
  module Request
    class Bookmark
      def initialize(pseud_id, id, url, author, title, summary, fandom_string, rating_string, category_string,
                     collection_names, notes, tag_string, private, rec)
        @pseud_id = pseud_id
        @id = id
        @url = url
        @author = author
        @title = title
        @summary = summary
        @fandom_string = fandom_string
        @rating_string = rating_string
        @category_string = category_string
        @collection_names = collection_names
        @notes = notes
        @tag_string = tag_string
        @private = private
        @rec = rec
      end
    end # BookmarkRequest
  end # Request
end # OtwArchive

