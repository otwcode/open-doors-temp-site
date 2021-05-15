module ApplicationHelper

  def item_id(type, id)
    "#{type}-#{id}"
  end

  def self.broadcast_message(message, id, current_user, processing_status: "none", response: {}, type: "author")
    status = (["importing", "imported", "checking"].include? processing_status) ? processing_status : ""
    status_hash = case status
                  when "importing"
                    { isImporting: true }
                  when "imported"
                    { isImported: true }
                  when "checking"
                    { isChecking: true }
                  else
                    { isImporting: false, isChecking: false }
                  end
    ok_status = if response&.any? && response&.key?(:success)
                  response[:success]
                else
                  false
                end
    broadcast = {
      is_ok: ok_status,
      message: "#{DateTime.now.strftime("%F %T %z")}\n#{current_user&.name || 'Anonymous'}: #{message}",
      response: response
    }.merge!(status_hash)
    broadcast["#{type}_id"] = id
    ActionCable.server.broadcast BROADCAST_CHANNEL, broadcast
  end
end # ApplicationHelper
