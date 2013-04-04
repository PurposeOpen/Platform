module CopyAttributeWithNextVersion

  def copy_attribute_with_next_version(attribute_name)
    klass = self.class
    arel_table = klass.arel_table
    attribute_value = remove_version_if_present(self.send(attribute_name))
    search_term = "#{attribute_value}(%)"
    regex = /#{Regexp.escape(attribute_value)}\((\d*)\)$/
    values = klass.where(arel_table[attribute_name].matches(search_term)).all.map(&attribute_name)
    next_version = values.collect {|value| regex.match(value)[1].to_i }.max.to_i + 1
    "#{attribute_value}(#{next_version})"
  end

  private

  def remove_version_if_present(value)
    regex = /(.*)\((\d*)\)$/
    matchdata = regex.match(value)
    matchdata.nil? ? value : matchdata[1]
  end

end

ActiveRecord::Base.send(:include, CopyAttributeWithNextVersion)