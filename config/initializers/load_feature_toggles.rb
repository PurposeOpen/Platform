Rails.application.config.to_prepare do
  Feature.load_config "#{Rails.root}/config/feature_toggles.yml"
end
