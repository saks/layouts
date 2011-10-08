class Item
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :image, styles: {
    medium: ["660x300#", :png],
  }

  field :tags, type: Array, default: []
  field :name

  validates_attachment_presence :image

  set_callback(:save, :after) do |item|
    item.tags.each { |tag| REDIS.sadd tag, item.id }
  end

  def tags=(tags)
    write_attribute :tags, tags.is_a?(String) ? Tag.fix(tags) : tags
  end

  def prepopulate_tags
    tags.map { |tag| {id: tag, name: tag} }
  end

  #TODO: add sorting here
  def self.search_by_tag(string)
    where :tags.in => Tag.split(string)
  end

end
