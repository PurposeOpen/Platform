require "spec_helper"
require "psych_to_json_converter"

describe PsychToJsonConverter do

  before(:each) do
    @table_name = "action_sequences"
    @column_name = "options"
  end

  def execute_sql(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  def verify(yml, json)
    id = create_record(yml)
    PsychToJsonConverter.new(@table_name, @column_name).convert
    execute_sql("SELECT #{@column_name} from #{@table_name} where id = #{id}").first[0].should == json
  end

  def create_record(value)
    id = execute_sql("select max(id) from #{@table_name}").first[0].to_i + 1
    execute_sql("INSERT INTO #{@table_name} (id, #{@column_name}) VALUES (#{id}, '#{value}')")
    id
  end

  it "should convert the empty yaml column to empty json" do
    verify("--- {}\n", "{}")
    verify(nil, "{}")
  end

  it "should convert the hash column to json" do
    verify("--- !map:ActiveSupport::HashWithIndifferentAccess \nfacebook: http://www.facebook.com/AllOutOrg?ref=ts",
           "{\"facebook\":\"http://www.facebook.com/AllOutOrg?ref=ts\"}")
  end

  it "should convert the array column to json" do
    verify("---\n- en\n\n\n- es", "[\"en\",\"es\"]")
  end

  it "should convert only the records which match the conditions" do
    yml = "--- {}\n"
    id1 = create_record(yml)
    id2 = create_record(yml)
    PsychToJsonConverter.new(@table_name, @column_name, "id = #{id1}").convert
    execute_sql("SELECT #{@column_name} from #{@table_name}  where id = #{id1}").first[0].should == "{}"
    execute_sql("SELECT #{@column_name} from #{@table_name}  where id = #{id2}").first[0].should == yml
  end

end