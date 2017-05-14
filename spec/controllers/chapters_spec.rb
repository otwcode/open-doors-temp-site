require 'rails_helper'

describe ChaptersController do
  it 'should show a single chapter' do
    chapter = FactoryGirl.create(:chapter, audit_comment: "New chapter")
    get :show, params: { id: chapter.id }
    expect(response).to render_template(:show)
  end
end
