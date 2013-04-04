# If an s3.yml file exists, use the key, secret key, and bucket values from there.
S3 = { :enabled => false}
if File.exists?("#{Rails.root}/config/s3.yml")
  s3_config = YAML.load_file("#{Rails.root}/config/s3.yml")
  if s3_config[Rails.env]
    S3[:enabled] = true
    S3[:key] = s3_config[Rails.env]['key']
    S3[:secret] = s3_config[Rails.env]['secret']
    S3[:bucket] = s3_config[Rails.env]['bucket']
  end
end

# Otherwise, pull them from the environment. (Heroku does this)
if !S3[:enabled] && ENV['AWS_ACCESS_KEY_ID']
  S3[:enabled] = true
  S3[:key] = ENV['AWS_ACCESS_KEY_ID']
  S3[:secret] = ENV['AWS_SECRET_ACCESS_KEY']
  S3[:bucket] = ENV['S3_BUCKET_NAME']
end

if S3[:enabled]
  Rails.logger.info "Configured for Amazon S3 with key #{S3[:key]} and bucket #{S3[:bucket]}"
else
  Rails.logger.warn "Disabling Amazon S3 integration; falling back to local storage. This will NOT work on Heroku's readonly filesystem. See doc/AmazonS3.rdoc"
end
