module OtwArchive
  module Request
    # noinspection RubyTooManyInstanceVariablesInspection
    class Work
      # mainly for testing :/
      attr_reader :id, :chapter_urls, :notes, :language_code

      # @param [String] title
      def initialize(title, external_author_name, external_author_email, external_coauthor_name, external_coauthor_email,
                     collection_names, fandoms, warnings, characters, rating, relationships, language_code, categories,
                     additional_tags, notes, id, summary, chapter_urls)
        @title = title
        @external_author_name = external_author_name
        @external_author_email = external_author_email
        @external_coauthor_name = external_coauthor_name
        @external_coauthor_email = external_coauthor_email
        @collection_names = collection_names
        @fandoms = fandoms
        @warnings = warnings
        @characters = characters
        @rating = rating
        @relationships = relationships
        @language_code = language_code
        @categories = categories
        @additional_tags = additional_tags
        @notes = notes
        @id = id
        @summary = summary
        @chapter_urls = chapter_urls
      end
    end
  end # Request
end # OtwArchive
