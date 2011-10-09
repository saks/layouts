module Tag
  CLOUD_KEY                 = "tags_cloud"
  SITE_IDS_CACHE_KEY_PREFIX = "site_ids_for_tag:%s"
  UNIONS_CACHE_KEY_PREFIX   = "cached_unions_for_tag:%s"
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


    def find_items_by(string)
      tags = split string
      item_ids = if 1 == tags.size
        REDIS.zrange cache_key_for(tags.first), 0, -1

      elsif tags.size > 1
        key = 'union_by:' + tags.sort.join(',')

        # do not create if it already exists.
        # it should be expired after tags update on any item with tags key contains
        unless REDIS.exists key
          REDIS.zunionstore key, cache_key_for(tags)
          remember_cached_union_for tags, key
        end

        best = REDIS.zrevrange key, 0, -1
      else
        []
      end

      Item.find_by_ids_preserving_order item_ids
    end


    # utility function to make array from dirty string with tags
    def split(string)
      string.split(DELIMITER).map(&:strip).uniq.delete_if &:empty?
    end


    # returns key for tag's set with site_ids
    # it array was passed it will return an array of valid keys
    def cache_key_for(names)
      if names.is_a? Array
        names.map { |tag_name| cache_key_for tag_name }
      else
        SITE_IDS_CACHE_KEY_PREFIX % names
      end
    end


    # returns score for specified tag name
    def score_for(tag_name)
      (REDIS.zscore(CLOUD_KEY, tag_name) or 0).to_i
    end


    # handles all changes after adding new tag to item
    def stick_to(tag_name, item_id)
      REDIS.multi do
        REDIS.zadd cache_key_for(tag_name), 1, item_id
        stick tag_name
      end
    end


    # handles all changes after removing tag from item
    def take_off_from(tag_name, item_id)
      REDIS.multi do
        REDIS.zrem cache_key_for(tag_name), item_id
        take_off tag_name
      end
    end


    # handle tag_name popularity after adding to item
    def stick(tag_name)
      REDIS.zincrby CLOUD_KEY, 1, tag_name
    end

    # handle tag_name popularity after removing form item
    def take_off(tag_name)
      REDIS.zincrby CLOUD_KEY, -1, tag_name
    end


    # store key of union set for tag name
    def remember_cached_union_for(tag_name, key_to_remember)
      if tag_name.is_a? Array
        tag_name.each { |local_tag_name| remember_cached_union_for local_tag_name, key_to_remember }
      else
        set_key = UNIONS_CACHE_KEY_PREFIX % tag_name
        REDIS.sadd set_key, key_to_remember
      end
    end


    # returns set of remembered union set keys for tag name
    def remembered_unions_for(tag_name)
      key = UNIONS_CACHE_KEY_PREFIX % tag_name
      REDIS.smembers key
    end


    # expires all cached union sets for tag name
    def expire_unions_for_tags(tag_name)
      if tag_name.is_a? Array
        tag_name.each { |local_tag_name| expire_unions_for_tags local_tag_name }
      else
        remembered_unions_for(tag_name).each { |key| REDIS.del key }
        REDIS.del UNIONS_CACHE_KEY_PREFIX % tag_name
      end
    end

    def all
      REDIS.zrangebyscore CLOUD_KEY, MINUS_INFINITY, PLUS_INFINITY
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

    def cloud
      REDIS.zrevrange CLOUD_KEY, 0, -1, withscores: true
    end

    def seed
      destroy_all
      ["Asian", "Contemporary", "Eclectic", "Mediterranean", "Modern", "Traditional", "Tropical", "Bathroom", "Bedroom", "Closet", "Dining Room", "Entry", "Exterior", "Family Room", "Hall", "Home Office", "Kids", "Kitchen", "Landscape", "Laundry Room", "Living Room", "Media Room", "Patio", "Pool", "Porch", "Powder Room", "Staircase", "Wine Cellar"].each do |tag_name|
        REDIS.zadd CLOUD_KEY, 0, tag_name
      end
    end
  end

end
