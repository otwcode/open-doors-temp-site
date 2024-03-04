FactoryBot.define do
  sequence :id do |n|
    n
  end

  factory :story do
    author
    id { generate :id }
    chapters { create_list(:chapter, 2, story_id: id, audit_comment: "A story") }
    audit_comment {"Test"}
  end

  factory :story_link do
    author
    id { generate :id }
    audit_comment {"Test"}
  end

  factory :author do
    id { generate :id }
    sequence(:name) { |n| "Author name #{n}" }
    audit_comment {"Test"}

    # user_with_posts will create post data after the user has been created
    factory :author_with_stories do
      transient do
        stories_count { 5 }
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including transient
      # attributes; `create_list`'s second argument is the number of records to create
      after(:create) do |author, evaluator|
        create_list(:story, evaluator.stories_count, author: author, audit_comment: "A story")
      end
    end
  end

  factory :chapter do
    story
    id { generate :id }
    audit_comment {"Test"}
  end

  factory :archive_config do
    key { APP_CONFIG[:sitekey] }
    name { APP_CONFIG[:name] }
    host { "local" }
    initialize_with { ArchiveConfig.where(key: key).first_or_create }
  end
end
