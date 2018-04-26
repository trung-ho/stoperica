require 'rails_helper'

RSpec.describe "start_numbers/new", type: :view do
  before(:each) do
    assign(:start_number, StartNumber.new(
      :value => "MyString",
      :tag_id => "MyString",
      :race_result => ""
    ))
  end

  it "renders new start_number form" do
    render

    assert_select "form[action=?][method=?]", start_numbers_path, "post" do

      assert_select "input#start_number_value[name=?]", "start_number[value]"

      assert_select "input#start_number_tag_id[name=?]", "start_number[tag_id]"

      assert_select "input#start_number_race_result[name=?]", "start_number[race_result]"
    end
  end
end
