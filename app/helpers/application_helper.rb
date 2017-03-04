module ApplicationHelper
  include OtwArchive
  include OtwArchive::Request

  def story_to_work(story)
    Request::Work.new(
      story.title,
      story.author.name,
      story.author.email,
      (story.coauthor.nil? ? "" : story.coauthor.name),
      (story.coauthor.nil? ? "" : story.coauthor.email),
      "",
      story.fandoms,
      story.warnings,
      story.characters,
      story.rating,
      story.relationships,
      story.categories,
      story.tags,
      story.notes,
      story.id,
      story.summary,
      story.chapters.map { |c| url_for(c) }
  )
  end

  def bookmark_to_ao3(bookmark, archivist)
    Request::Bookmark.new(
        pseud_id = archivist,
        id = bookmark.id,
        url = bookmark.url,
        bookmark.author.name,
        bookmark.title,
        bookmark.summary,
        bookmark.fandoms,
        bookmark.rating,
        bookmark.categories,
        collection_names = "",
        bookmark.notes,
        bookmark.tags,
        private = false,
        rec = false
    )
  end
end
