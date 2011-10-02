class Item
  include Mongoid::Document
  include Mongoid::Paperclip

  has_mongoid_attached_file :image

  field :tags, type: 'Array'
  field :name

end
