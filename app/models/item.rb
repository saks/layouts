class Item
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :image, styles: {
    medium: ["660x300#", :png],
  }

  field :tags, type: 'Array', default: []
  field :name

  validates_attachment_presence :image

  def tags=(tags)
    if tags.is_a? String
      write_attribute :tags, Tag.fix(tags)
    else
      write_attribute :tags, tags
    end
  end

  def prepopulate_tags
    tags.map { |tag| {id: tag, name: tag} }
  end

end
