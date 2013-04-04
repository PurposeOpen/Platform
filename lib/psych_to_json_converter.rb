class PsychToJsonConverter

  def initialize(table_name, column_name, conditions = nil)
    @table_name = table_name
    @column_name = column_name
    @conditions = conditions
  end

  def convert
    select_sql = "select id, #{@column_name} from #{@table_name}"
    select_sql << " where #{@conditions}" if @conditions.present?
    result_set = ActiveRecord::Base.connection.execute(select_sql)
    result_set.each do |record|
      begin
        id = record[0]
        column_value = record[1]
        yaml = deserialized_yaml(column_value)
        raise Exception if yaml.instance_of?(String)
        json_value = serialized_json(yaml)
        klass_name.update_all(["#{@column_name} = ?", json_value], {id: id})
      rescue Exception => e
        p e
        p "#{@table_name} #{id} failed"
      end
    end
  end

  private

  def deserialized_yaml(value)
    cleaned_value = (value || '{}').gsub("\\\\", "\\")
    YAML.load(cleaned_value) || {}
  end

  def serialized_json(value)
    JSON.dump(value)
  end

  def klass_name
    @table_name.classify.constantize
  end

end