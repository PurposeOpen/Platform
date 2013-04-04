require 'psych_to_json_converter'

class ConvertSerializedAttributesFromYamlToJson < ActiveRecord::Migration
  def change
    PsychToJsonConverter.new("pages", "required_user_details", "type='ActionPage'").convert
    PsychToJsonConverter.new("action_sequences", "options").convert
    PsychToJsonConverter.new("action_sequences", "enabled_languages").convert
    PsychToJsonConverter.new("content_modules", "options").convert
    PsychToJsonConverter.new("get_togethers", "options").convert
    PsychToJsonConverter.new("homepage_contents", "follow_links").convert
    PsychToJsonConverter.new("lists", "rules").convert
    PsychToJsonConverter.new("list_intermediate_results", "data").convert
    PsychToJsonConverter.new("list_intermediate_results", "queries").convert
  end
end
