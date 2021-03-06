class StatsController < ApplicationController
  before_action :authorize

  def index
  end

  def stats
    stats = gather_stats
    render json: stats.to_h.to_json, content_type: "application/json"
  end

  def author_stats(authors)
    authors_imported, authors_not_imported, authors_dni = Array.new(3) { [] }
    authors.each do |a|
      authors_imported << a if a.all_imported?
      authors_dni << a if a.do_not_import
      authors_not_imported << a if !a.all_imported? && !a.do_not_import
    end

    OpenStruct.new(
        all: authors.size,
        imported: authors_imported.size,
        not_imported: authors_not_imported.size,
        dni: authors_dni.size
    )
  end

  def grouped_author_stats(authors)
    grouped_authors = authors.group_by { |author| author.name.downcase.first }
    all_imported = {}
    grouped_authors.each do |letter, group|
      is_imported = group.all? { |a| a.all_imported? }
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

  def story_stats(stories)
    stories_imported, stories_dni, stories_not_imported = Array.new(3) { [] }
    stories.each do |s|
      stories_imported << s if s.imported
      stories_dni << s if s.do_not_import
      stories_not_imported << s if !s.imported && !s.do_not_import
    end
    OpenStruct.new(
        all: stories.size,
        imported: stories_imported.size,
        not_imported: stories_not_imported.size,
        dni: stories_dni.size
    )
  end

  def gather_stats(authors = nil, stories = nil, story_links = nil)
    authors ||= Author.with_stories_or_story_links

    stories ||= Story.all.to_a
    story_links ||= StoryLink.all.to_a

    @stats = OpenStruct.new(
      authors: author_stats(authors),
      letters: grouped_author_stats(authors),
      stories: story_stats(stories),
      story_links: story_stats(story_links)
    )
  end
end
