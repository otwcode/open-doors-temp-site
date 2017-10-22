class ArchiveConfigsController < ApplicationController
  include Item
  
  before_action :authorize

  # GET /archive_configs/1
  def show
  end

  # GET /archive_configs/1/edit
  def edit
  end

  # PATCH/PUT /archive_configs/1
  def update
    notice = "Archive config was successfully updated."
    host = params[:archive_config][:host]
    new_host = host.to_sym != @active_host
    
    if @archive_config.update(archive_config_params)
      if new_host
        load_config
        reset_flags
        notice << " The host has been changed: all authors, stories and storylinks are now marked as ready to import."
      end
      redirect_to @archive_config, notice: notice
    else
      render :edit
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def archive_config_params
    params.fetch(:archive_config, {}).permit(:key, :name, :fandom, :stories_note, :bookmarks_note,
                                             :send_email, :post_preview, :items_per_page,
                                             :archivist, :collection_name, :imported, :not_imported,
                                             :host)
  end
end
