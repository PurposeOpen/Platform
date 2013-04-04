module Sass::Script::Functions
  def _ify(string)
    assert_type string, :String
    Sass::Script::String.new(string.value.gsub(/[-]/, '_'))
  end
end
