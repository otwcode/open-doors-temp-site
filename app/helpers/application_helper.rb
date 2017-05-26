module ApplicationHelper
  include OtwArchive
  include OtwArchive::Request

  def item_id(type, id)
    "#{type}-#{id}"
  end

  def story_to_work(story, collection)
    Request::Work.new(
      story.title,
      story.author.name,
      story.author.email,
      (story.coauthor.nil? ? "" : story.coauthor.name),
      (story.coauthor.nil? ? "" : story.coauthor.email),
      collection,
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

  def storylink_to_bookmark(bookmark, archivist, collection)
    puts bookmark.inspect
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
      bookmark.relationships,
      bookmark.characters,
      collection,
      bookmark.notes,
      bookmark.tags,
      false,
      false
    )
  end

  def update_item(type, response)
    puts "\nupdate_item: #{response.inspect}"

    item = nil
    if type == :story
      item = Story.find_by_id(response[:original_id])
    elsif type == :bookmark
      item = StoryLink.find_by_id(response[:original_id])
    end

    if response[:status].in? ["ok", "created", "already_imported"]
      if item.ao3_url != response[:archive_url] || (item.ao3_url == response[:archive_url] && !item.imported)
        response[:messages] << "Archive URL updated to #{response[:archive_url]}."
        item.update_attributes!(
          imported: true,
          ao3_url: response[:archive_url],
          audit_comment: response[:messages].join(" ")
        )
      else
        response[:messages] << "Item is already imported at #{response[:archive_url]}."
      end
    elsif response[:status].in? ["unprocessable_entity", "bad_request"]
      audit = Audited::Audit.new(
        auditable_id: item.id,
        auditable_type: item.class.name,
        associated_id: item.author.id,
        associated_type: item.author.class.name,
        comment: "#{response[:status].humanize}: #{response[:messages].join(' ')}".truncate(254)
      )
      audit.save!
    end
    response[:author_id] = item.author.id
    response
  end
end # ApplicationHelper
