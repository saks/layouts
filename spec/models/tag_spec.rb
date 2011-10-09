require 'spec_helper'

describe Tag do

  let(:dirty_string) { ",foo, bar;buz ;foo" }

  it "splits string of tags" do
    Tag.split(dirty_string).should == %w[foo bar buz]
  end

  it "sorts search result" do
    Tag.stick 'aac'
    Tag.stick 'aab'
    Tag.stick 'aaa'

    Tag.search('a').map {|t| t[:id]}.should == %w[aaa aab aac]
    Tag.stick 'aaa'
    Tag.search('a').map {|t| t[:id]}.should == %w[aaa aab aac]
  end

  it 'can stick, take off tag and returns right score' do
    Tag.score_for('foo').should be 0
    2.times { Tag.stick 'foo' }
    Tag.score_for('foo').should be 2
    Tag.take_off 'foo'
    Tag.score_for('foo').should be 1
  end

  it "should generate different site cache keys" do
    key1 = Tag.cache_key_for 'foo'
    key2 = Tag.cache_key_for 'bar'

    diff = ''
    key1.each_char.with_index do |char, i|
      diff << char unless char == key2[i]
    end

    diff.should eql 'foo'
  end

  it "searches by one tag" do
    Tag.should respond_to :find_items_by
    Tag.find_items_by(dirty_string).should == []

    item = FactoryGirl.create :item, tags: dirty_string

    item.tags.each do |tag_name|
      Tag.find_items_by(tag_name).first.should == item
    end
  end

  it "searches by more than one tag" do
    item3 = FactoryGirl.create :item, tags: 'foo,tag2'
    item2 = FactoryGirl.create :item, tags: 'foo,bar,tag1'
    item1 = FactoryGirl.create :item, tags: 'foo,bar,buz'

    result = Tag.find_items_by('buz,bar,foo').to_a

    result.should == [item1, item2, item3]
  end

  it "should update cached union sets" do
    item3 = FactoryGirl.create :item, tags: 'foo,tag3'
    item2 = FactoryGirl.create :item, tags: 'foo,bar,tag2'
    item1 = FactoryGirl.create :item, tags: 'foo,bar,buz'

    Tag.find_items_by('buz,bar,foo,tag1').should == [item1, item2, item3]

    item2.tags = 'foo,bar,tag1,buz'
    item2.save!

    Tag.find_items_by('buz,bar,foo,tag1').should == [item2, item1, item3]
  end

  it "should remember union keys for tags" do
    Tag.remembered_unions_for('foo').size.should == 0

    Tag.remember_cached_union_for 'foo', 'key1'

    remembered = Tag.remembered_unions_for('foo')
    remembered.size.should == 1
    remembered.should include 'key1'
  end

  it "should expire union sets for tags" do
    REDIS.set 'key1', 'something'
    Tag.remember_cached_union_for 'foo', 'key1'

    REDIS.exists('key1').should be true

    Tag.expire_unions_for_tags 'foo'

    REDIS.exists('key1').should be false
  end
end
