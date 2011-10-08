module Tag
  KEY_NAME  = "tags-#{Rails.env}"
  DELIMITER = /\s?(?:,|;)\s?/

  class << self
    def search(term, add_new = false)
      re = Regexp.new term, 'i'

      result = all.grep(re).map do |tag|
        {id: tag}
      end

      result << {id: term} if add_new

      result
    end

    def split(string)
      string.split(DELIMITER).map(&:strip).uniq.delete_if &:empty?
    end

    # normalize and
    def fix(string)
      split(string).each { |tag| add tag }
    end

    def add(tag)
      REDIS.zincrby KEY_NAME, 1, tag
    end

    def all
      REDIS.zrange KEY_NAME, 0, -1, withscores: false
    end

    def count
      REDIS.zcard KEY_NAME
    end

    def destroy_all
      REDIS.zremrangebyrank KEY_NAME, 0, -1
    end

    def exists?(name)
      !REDIS.zrank(KEY_NAME, name).nil?
    end
  end

end
