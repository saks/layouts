require 'spec_helper'

describe "items/show.html.erb" do
  before(:each) do
    @item = assign(:item, stub_model(Item))
  end

  it "renders attributes in <p>" do
    render

    assert_select 'form[action=?]', add_comment_to_item_path(@item)
  end
end
