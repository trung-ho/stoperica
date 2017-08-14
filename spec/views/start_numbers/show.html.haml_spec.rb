require 'rails_helper'

RSpec.describe "start_numbers/show", type: :view do
  before(:each) do
    @start_number = assign(:start_number, StartNumber.create!(
      :value => "Value",
      :tag_id => "Tag",
      :race_result => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Value/)
    expect(rendered).to match(/Tag/)
    expect(rendered).to match(//)
  end
end
