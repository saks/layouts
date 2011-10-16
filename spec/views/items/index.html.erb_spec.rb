require 'spec_helper'

describe "items/index.html.erb" do
  before(:each) do
    view.lookup_context.prefixes << 'application'
    assign(:items, Kaminari.paginate_array([
      stub_model(Item),
      stub_model(Item)
    ]).page(1).per(2))
  end

  it "renders a list of items" do
    render
  end
end
