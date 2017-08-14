require 'rails_helper'

RSpec.describe "start_numbers/edit", type: :view do
  before(:each) do
    @start_number = assign(:start_number, StartNumber.create!(
      :value => "MyString",
      :tag_id => "MyString",
      :race_result => ""
    ))
  end

  it "renders the edit start_number form" do
    render

    assert_select "form[action=?][method=?]", start_number_path(@start_number), "post" do

      assert_select "input#start_number_value[name=?]", "start_number[value]"

      assert_select "input#start_number_tag_id[name=?]", "start_number[tag_id]"

      assert_select "input#start_number_race_result[name=?]", "start_number[race_result]"
    end
  end
end
