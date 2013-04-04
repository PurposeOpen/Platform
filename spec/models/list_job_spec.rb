require "spec_helper"

# describe ListJob do
#   before(:each) do
#     movement = create(:movement)
#     @count_sql = User.select("COUNT(DISTINCT(users.id)) AS count").where(movement_id: movement.id).to_sql
#     @language_breakdown_sql = User.select("COUNT(DISTINCT `users`.`id`) AS count_id, languages.name AS languages_name")
#                                   .joins("LEFT OUTER JOIN `languages` ON `languages`.`id` = `users`.`language_id`")
#                                   .where(movement_id: movement.id)
#                                   .group("languages.name").to_sql
#     @intermediate_result = create(:list_intermediate_result, list: create(:list))
#     @language_name_1 = "English"
#     @language_name_2 = "Portuguese"
#     english = create(:language, name: @language_name_1)
#     portuguese = create(:language, name: @language_name_2)
#     2.times { create(:user, language: english, movement: movement) }
#     create(:user, language: portuguese, movement: movement)
#   end

#   it "should perform the job and update intermediate result" do
#     list_job = ListJob.new(@count_sql, @language_breakdown_sql, @intermediate_result)
#     list_job.perform

#     @intermediate_result.reload
#     @intermediate_result.should be_ready
#     data = @intermediate_result.data
#     data[:sql].should == @count_sql
#     data[:total_time].should_not be_nil
#     data[:number_of_selected_users].should == 3
#     data[:number_of_selected_users_by_language].should == {@language_name_1 => 2, @language_name_2 => 1}
#   end

#   it "should update total time" do
#     total_time = 0.7
#     Benchmark.stub(:measure).and_return(stub("benchmark", total: total_time))
#     list_job = ListJob.new(@count_sql, @language_breakdown_sql, @intermediate_result)
#     list_job.perform

#     @intermediate_result.reload
#     @intermediate_result.data[:total_time].should == "0.7000"
#   end

# end