require 'spec_helper'

describe Item do

  let(:dirty_string_of_tags) { ",foo, bar;buz ;foo" }
  let(:parsed_tags) { Tag.split dirty_string_of_tags }

  context "tags processing" do
    before :each do
      @item = FactoryGirl.build :item
    end

    it 'should process passed tags as a string' do
      @item.tags = dirty_string_of_tags
    end

    it 'should process passed tags as an array' do
      @item.tags = Tag.split dirty_string_of_tags
    end

    after :each do
      @item.save!
      @item.tags.should == parsed_tags
    end
  end

  it "should create non existing tags" do
    Tag.count.should be 0
    FactoryGirl.create :item, tags: dirty_string_of_tags
    Tag.count.should be 3
  end

  it "should return prepopulate tags data" do
    item = FactoryGirl.create :item, tags: dirty_string_of_tags

    item.prepopulate_tags.should eq parsed_tags.map{|t| {id: t, name: t}}
  end

  it "should search by tag" do
    i1 = FactoryGirl.create :item, tags: 'foo,bar'
    i2 = FactoryGirl.create :item, tags: 'foo'
    i3 = FactoryGirl.create :item, tags: 'bar,buz'

    Item.search_by_tag('foo').should eq [i1, i2]
    Item.search_by_tag('bar').should eq [i1, i3]
    Item.search_by_tag('buz').should eq [i3]
    Item.search_by_tag('foo,buz').to_a.should eq [i1, i2, i3]
    Item.search_by_tag(dirty_string_of_tags).should eq [i1, i2, i3]
  end

end
