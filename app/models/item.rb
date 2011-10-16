class Item
  include Mongoid::Document
  include Mongoid::Paperclip

  paginates_per 5

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

      if old_tags
        (old_tags - not_changed).each { |tag_name| Tag.take_off_from tag_name, item.id }
        Tag.expire_unions_for_tags old_tags
      end

      if new_tags
        (new_tags - not_changed).each { |tag_name| Tag.stick_to      tag_name, item.id }
        Tag.expire_unions_for_tags new_tags
      end
    end
  end

  def tags=(tags)
    write_attribute :tags, tags.is_a?(String) ? Tag.split(tags) : tags
  end

  def prepopulate_tags
    tags.map { |tag| {id: tag} }
  end

  def self.find_by_ids_preserving_order(ids)
    items_by_ids = where(:_id.in => ids).inject({}) do |acc, item|
      acc[item.id.to_s] = item
      acc
    end

    ids.map(&:to_s).inject([]) do |acc, id|
      acc << items_by_ids[id]
    end
  end

end
