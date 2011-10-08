class Item
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :image, styles: {
    medium: ["660x300#", :png],
  }

  field :tags, type: Array, default: []
  field :name

  validates_attachment_presence :image

  set_callback(:save, :before) do |item|
    if item.changes['tags']
      old_tags, new_tags = item.changes['tags']

      not_changed = (new_tags || []) & (old_tags || [])

      (old_tags - not_changed).each do |tag_name|
        item.remove_tag tag_name
      end if old_tags

      (new_tags - not_changed).each do |tag_name|
        item.stick_tag tag_name
      end if new_tags
    end
  end

  def tags=(tags)
    write_attribute :tags, tags.is_a?(String) ? Tag.split(tags) : tags
  end

  def stick_tag(tag_name)
    REDIS.multi do
      REDIS.sadd Tag::cache_key_for(tag_name), id
      Tag::stick tag_name
    end
  end

  def remove_tag(tag_name)
    REDIS.multi do
      REDIS.srem Tag::cache_key_for(tag_name), id
      Tag::take_off tag_name
    end
  end

  def prepopulate_tags
    tags.map { |tag| {id: tag} }
  end

  #TODO: add sorting here
  def self.search_by_tag(string)
    where :tags.in => Tag.split(string)
  end

end
