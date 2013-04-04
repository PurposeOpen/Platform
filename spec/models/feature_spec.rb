require "spec_helper"

describe Feature do
	before(:each) do
		# nasty hack to keep tests from interfering with one another
		Feature.clean
	end

	describe "initialization" do
		it "should load features from config file" do
			Feature.load_config "spec/fixtures/feature_toggles.yml"

			Feature[:features_1][:features_1_1][:feature_A_enabled].should be_true
			Feature[:features_1][:features_1_2][:feature_C_enabled].should be_true
			Feature[:features_2][:feature_D_enabled].should be_true
			Feature[:features_2][:features_2_1][:features_2_1_1][:feature_E_enabled].should be_false
			Feature[:feature_F_enabled].should be_true
 		end

 		it "should throw error if config file doesn't exist" do
 			Rails.logger.should_receive(:fatal)

 			lambda { Feature.load_config "unexistent_file.yml" }.should raise_exception
 		end

 		it "should throw error if accessed before being initialized" do
 			Rails.logger.should_receive(:error)

 			lambda { Feature[:feature_A] }.should raise_exception(FeatureNotInitializedError)
 		end
	end

	describe "override" do
		it "environment values should take precedence on config file values" do
			ENV['feature_F_enabled'] = 'false'

			Feature.load_config "spec/fixtures/feature_toggles.yml"

			YAML.load_file("spec/fixtures/feature_toggles.yml")['feature_F_enabled'].should be_true
			Feature[:feature_F_enabled].should be_false
		end

		it "nested levels should be represented by dots on environment variables" do
			ENV['features_1.features_1_1.feature_A_enabled'] = 'false'

			Feature.load_config "spec/fixtures/feature_toggles.yml"

			YAML.load_file("spec/fixtures/feature_toggles.yml")['features_1']['features_1_1']['feature_A_enabled'].should be_true
			Feature[:features_1][:features_1_1][:feature_A_enabled].should be_false
		end
	end
end