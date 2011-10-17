class Comment
  include Mongoid::Document

  field :text, default: ''

  validates_presence_of :text

  embedded_in :item
end
