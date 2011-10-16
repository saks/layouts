class Suite
  include Mongoid::Document

  has_many :items
end
