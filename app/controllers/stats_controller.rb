class StatsController < ApplicationController
  before_action :authorize

  def index
  end

  def stats
    stats = gather_stats
    render json: stats.to_h.to_json, content_type: "application/json"
  end

  def grouped_author_stats(authors, imported)
    grouped_authors = authors.group_by { |author| author.name.downcase.first }
    all_imported = {}
    grouped_authors.each do |letter, group|
      is_imported = group.all? { |a| imported.include?(a.id) }
      if letter =~ /[0-9a-zA-Z]/
        all_imported[letter] = is_imported
      else
        if all_imported["*"].nil?
          all_imported["*"] = is_imported
        else
          all_imported["*"] = all_imported["*"] && is_imported
        end
      end
    end
    imported_letters, not_imported_letters = all_imported.partition { |_, v| v }

    OpenStruct.new(
      all: grouped_authors.keys.size,
      imported: imported_letters,
      not_imported: not_imported_letters
    )
  end

  def item_stats(type)
    OpenStruct.new(
        all: type.count,
        imported: type.where(imported: true).count,
        not_imported: type.where("imported = false AND do_not_import = false").count,
        dni: type.where(do_not_import: true).count
    )
  end

  def gather_stats
    authors = Author.with_stories_or_story_links
    imported = Author.all_imported

    @stats = OpenStruct.new(
      authors: item_stats(Author),
      letters: grouped_author_stats(authors, imported),
      stories: item_stats(Story),
      story_links: item_stats(StoryLink)
    )
  end
end
