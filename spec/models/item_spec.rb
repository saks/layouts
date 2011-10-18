require 'spec_helper'

describe Item do

  it { should embed_many :comments }
  it { should belong_to :suite }

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

  it "should return prepopulate tags data" do
    item = FactoryGirl.create :item, tags: dirty_string_of_tags

    item.prepopulate_tags.should eq parsed_tags.map{|t| {id: t}}
  end

  it "should manage tags on update" do
    Tag.count_sticked.should be 0

    it1 = FactoryGirl.create :item, tags: %w[foo]

    Tag.count_sticked.should be 1
    Tag.score_for('foo').should be 1

    it2 = FactoryGirl.create :item, tags: %w[foo bar]

    Tag.count_sticked.should be 2
    Tag.score_for('foo').should be 2
    Tag.score_for('bar').should be 1

    it1.update_attribute :tags, []

    Tag.count_sticked.should be 2
    Tag.score_for('foo').should be 1
    Tag.score_for('bar').should be 1

    it2.update_attribute :tags, []

    Tag.count_sticked.should be 0
    Tag.score_for('foo').should be 0
    Tag.score_for('bar').should be 0

    it1.update_attribute :tags, %w[foo buz]

    Tag.count_sticked.should be 2
    Tag.score_for('foo').should be 1
    Tag.score_for('buz').should be 1
  end

  it "should search by ids with correct order" do
    it1 = FactoryGirl.create :item
    it2 = FactoryGirl.create :item
    it3 = FactoryGirl.create :item

    result = Item.find_by_ids_preserving_order [it3.id, it1.id, it2.id]

    result.should == [it3, it1, it2]
  end

  describe '#suggestions' do
    it 'should return other items from suite' do
      it1 = FactoryGirl.create :item
      it2 = FactoryGirl.create :item

      suite = FactoryGirl.create :suite, items: [it1, it2]

      result = it1.suggestions.to_a

      result.size.should be 1
      result.should include it2
    end

    it 'should return items suggested by tags' do
      it1 = FactoryGirl.create :item, tags: 'foo'
      it2 = FactoryGirl.create :item, tags: 'foo,bar'
      it3 = FactoryGirl.create :item, tags: 'foo,bar,buz'

      result = it1.suggestions.to_a

      result.size.should be 2
      result.should include it2
      result.should include it3
    end
  end

end
