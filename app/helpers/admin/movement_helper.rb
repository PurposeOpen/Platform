module Admin
  module MovementHelper
    def movement_languages(movement)
      languages = movement.non_default_languages.map(&:name).sort
      languages = ["#{movement.default_language.name} (default)",languages].flatten if movement.default_language
      languages.to_sentence
    end
  end
end