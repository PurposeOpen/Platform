class FeatureNotInitializedError < StandardError
end

class Feature
	def self.initialize
		@@initialized = false
	end

	def self.clean
		@@features = nil
		@@initialized = false
	end

	def self.load_config(config_file_path)
		begin			
			@@features = YAML.load_file(config_file_path)
		rescue Exception => ex
			Rails.logger.fatal("Error while loading #{config_file_path} file: #{ex}")
			raise ex
		end

		override_values_from_env @@features, []
		simbolize_features_keys @@features

		@@initialized = true
	end

	def self.[](key)
		if !@@initialized
			Rails.logger.error("Features were not initialized.\n'load_config' must be invoked with a valid configuration file before calling [] method.")
			raise FeatureNotInitializedError.new
		end

		@@features[key]
	end

	private

	def self.override_values_from_env(features_hash, level_keys)
		features_hash.each { |k,v|
			# nested keys on ENV must be concatenated using '.'
			# i.e.: to overrideFeature[:feature_A][:feature_A_1] use ENV['feature_A.feature_A_1']
			env_key = (level_keys.dup << k).join('.')
			if v.respond_to? :each
				override_values_from_env(v, level_keys.dup << k)
			elsif !ENV[env_key].nil?
				features_hash[k] = ENV[env_key] =~ /true/i
			end					
		}
	end

	def self.simbolize_features_keys(features_hash)
		features_hash.symbolize_keys!
		features_hash.values.each { |v| 
			if v.respond_to? :symbolize_keys!
				simbolize_features_keys v
			end
		}
	end
end