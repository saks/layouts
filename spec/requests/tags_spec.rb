require 'spec_helper'

describe "Tag" do
  describe "GET /tags" do
    it "responds with completion" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get '/tags?q=foo'
      response.status.should be(200)
      response.content_type.to_s.should eql 'application/json'
      #TODO: add data check
    end
  end
end
