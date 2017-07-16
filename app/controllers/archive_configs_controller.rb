class ArchiveConfigsController < ApplicationController
  before_action :set_archive_config, only: [:show, :edit, :update, :destroy]

  # GET /archive_configs/1
  def show
  end

  # GET /archive_configs/1/edit
  def edit
  end

  # PATCH/PUT /archive_configs/1
  def update
    if @archive_config.update(archive_config_params)
      redirect_to @archive_config, notice: 'Archive config was successfully updated.'
    else
      render :edit
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_archive_config
    @archive_config = @site_config
  end

  # Only allow a trusted parameter "white list" through.
  def archive_config_params
    params.fetch(:archive_config, {}).permit(:key, :name, :fandom, :stories_note, :bookmarks_note,
                                             :send_email, :post_preview, :items_per_page,
                                             :archivist, :collection_name, :imported, :not_imported)
  end
end
