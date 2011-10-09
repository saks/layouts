module Tag
  CLOUD_KEY                 = "tags_cloud"
  SITE_IDS_CACHE_KEY_PREFIX = "site_ids_for_tag_%s"
  DELIMITER                 = /\s?(?:,|;)\s?/
  MINUS_INFINITY            = '-INF'
  PLUS_INFINITY             = '+INF'

  class << self
    def search(term, add_new = false)
      re = Regexp.new term, 'i'

      result = all.sort.grep(re).map { |tag| {id: tag} }

      result << {id: term} if add_new

      result
    end

    def split(string)
      string.split(DELIMITER).map(&:strip).uniq.delete_if &:empty?
    end

    def cache_key_for(name)
      SITE_IDS_CACHE_KEY_PREFIX % name
    end

    # returns score for specified tag name
    def score_for(tag_name)
      (REDIS.zscore(CLOUD_KEY, tag_name) or 0).to_i
    end

    # increment score for specified tag name
    def stick(tag_name)
      REDIS.zincrby CLOUD_KEY, 1, tag_name
    end

    # descement score for specified tag name
    def take_off(tag_name)
      REDIS.zincrby CLOUD_KEY, -1, tag_name
    end

    def all
      REDIS.zrangebyscore CLOUD_KEY, MINUS_INFINITY, PLUS_INFINITY, withscores: false
    end

    def count
      REDIS.zcount CLOUD_KEY, MINUS_INFINITY, PLUS_INFINITY
    end

    def count_sticked
      REDIS.zcount CLOUD_KEY, 1, PLUS_INFINITY
    end

    def destroy_all
      REDIS.zremrangebyrank CLOUD_KEY, 0, -1
    end

    def exists?(name)
      !REDIS.zrank(CLOUD_KEY, name).nil?
    end

    def seed
      destroy_all
      ["Asian", "Contemporary", "Eclectic", "Mediterranean", "Modern", "Traditional", "Tropical", "Bathroom", "Bedroom", "Closet", "Dining Room", "Entry", "Exterior", "Family Room", "Hall", "Home Office", "Kids", "Kitchen", "Landscape", "Laundry Room", "Living Room", "Media Room", "Patio", "Pool", "Porch", "Powder Room", "Staircase", "Wine Cellar"].each do |tag_name|
        REDIS.zadd CLOUD_KEY, 0, tag_name
      end
    end
  end

end
