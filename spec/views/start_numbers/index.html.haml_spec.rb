require 'rails_helper'

RSpec.describe "start_numbers/index", type: :view do
  before(:each) do
    assign(:start_numbers, [
      StartNumber.create!(
        :value => "Value",
        :tag_id => "Tag",
        :race_result => ""
      ),
      StartNumber.create!(
        :value => "Value",
        :tag_id => "Tag",
        :race_result => ""
      )
    ])
  end

  it "renders a list of start_numbers" do
    render
    assert_select "tr>td", :text => "Value".to_s, :count => 2
    assert_select "tr>td", :text => "Tag".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
