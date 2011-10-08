REDIS_CONFIG = YAML.load_file(Rails.root.join 'config/redis.yml')[Rails.env]

REDIS = Redis.new host: REDIS_CONFIG['host'], port: REDIS_CONFIG['port'], db: REDIS_CONFIG['database']
