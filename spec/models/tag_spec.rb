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

end
