require 'spec_helper'

describe Comment do

  it { should be_embedded_in :item }
  it { should validate_presence_of :text }
  it { should have_fields :text }

  describe "when first created" do
    its(:text) { should eql '' }
  end

end
