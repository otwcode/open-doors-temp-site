module ApplicationHelper
  include OtwArchive
  include OtwArchive::Request

  def item_id(type, id)
    "#{type}-#{id}"
  end

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
        archivist,
        bookmark.id,
        bookmark.url,
        bookmark.author.name,
        bookmark.title,
        bookmark.summary,
        bookmark.fandoms,
        bookmark.rating,
        bookmark.categories,
        "",
        bookmark.notes,
        bookmark.tags,
        private: false,
        rec: false
    )
  end

  def update_item(type, response)
    puts "\nupdate_item: #{response.inspect}"

    work = nil
    if type == :story
      work = Story.find_by_id(response[:original_id])
    elsif type == :bookmark
      work = Bookmark.find_by_id(response[:original_id])
    end

    if (response[:status].in? ["ok", "created", "already_imported"]) && (work.ao3_url != response[:url])
        response[:messages] << "Archive URL updated to #{response[:url]}."
        work.update_attributes!(
          imported: true,
          ao3_url: response[:url],
          audit_comment: response[:messages].join(" ")
        )
    elsif response[:status] == "unprocessable_entity"
    end
    response
  end
end # ApplicationHelper
