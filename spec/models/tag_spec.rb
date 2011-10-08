require 'spec_helper'

describe Tag do

  let(:dirty_string) { ",foo, bar;buz ;foo" }

  it "splits string of tags" do
    Tag.split(dirty_string).should == %w[foo bar buz]
  end

  it "fixes tags" do
    Tag.count.should be 0

    result_of_split = Tag.split dirty_string
    result = Tag.fix dirty_string

    result.should == result_of_split

    result_of_split.each do |name|
      Tag.exists?(conditions: {name: name}).should be true
    end

    Tag.count.should be 3
  end

end
