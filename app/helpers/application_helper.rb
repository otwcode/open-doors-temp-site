module ApplicationHelper
  include OtwArchive
  include OtwArchive::Request

  def item_id(type, id)
    "#{type}-#{id}"
  end

  def update_item(type, response)
    puts "\nupdate_item: #{response.inspect}"

    item = nil
    if type == :story
      item = Story.find_by_id(response[:original_id])
    elsif type == :bookmark
      item = StoryLink.find_by_id(response[:original_id])
    end

    if response[:status].in? ["ok", "created", "already_imported", "found"]
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
    elsif response[:status].in? ["not_found"]
      if item.imported || item.ao3_url.present?
        response[:messages] << "Item has been deleted or host has changed."
        item.update_attributes!(
          imported: false,
          ao3_url: nil,
          audit_comment: response[:messages].join(" ")
        )
      else
        response[:messages] << "Item is already marked as not imported."
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
