class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :text, default: ''
  field :author_avatar_url
  field :author_name

  validates_presence_of :text


  embedded_in :item
end
