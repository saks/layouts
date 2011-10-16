class Collection
  include Mongoid::Document
  has_many :items
end
