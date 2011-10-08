#["Asian", "Contemporary", "Eclectic", "Mediterranean", "Modern", "Traditional", "Tropical", "Bathroom", "Bedroom", "Closet", "Dining Room", "Entry", "Exterior", "Family Room", "Hall", "Home Office", "Kids", "Kitchen", "Landscape", "Laundry Room", "Living Room", "Media Room", "Patio", "Pool", "Porch", "Powder Room", "Staircase", "Wine Cellar"]
class Tag
  include Mongoid::Document

  field :name

  DELIMITER = /\s?(?:,|;)\s?/

  def self.search(term, add_new)
    re = Regexp.new term, 'i'

    result = all.find_all { |tag| tag.name.match re }.map do |tag|
      {id: tag.id, name: tag.name}
    end

    result << {id: "CREATE_#{term}_END", name: term} if add_new

    result
  end

  def self.fix(string)
    result = string.split(DELIMITER).map(&:strip).uniq

    result.each do |tag|
      create(name: tag) unless exists?(conditions: {name: tag})
    end

    result
  end

end
