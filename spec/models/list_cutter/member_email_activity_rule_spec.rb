require "spec_helper"

describe ListCutter::MemberEmailActivityRule do
  describe "validations" do
    it { should validate_presence_of :range_operator }
    it { should ensure_inclusion_of(:range_operator).in_array(['more_than', 'less_than', 'equal_to']) }

    it { should validate_presence_of :activity_count }
    it { should validate_numericality_of(:activity_count).only_integer }
    it { should_not allow_value(-1).for(:activity_count) }

    it { should validate_presence_of :activity_type }

    it { should validate_presence_of :since_date }
    it { should allow_value(Date.yesterday.strftime("%m/%d/%Y")).for(:since_date) }
    it { should allow_value(Date.today.strftime("%m/%d/%Y")).for(:since_date) }
    it { should_not allow_value(Date.tomorrow.strftime("%m/%d/%Y")).for(:since_date) }
  end

  describe "to_relation" do
    describe "activity_types" do
      before(:each) do
        @email = create(:email)
        options = {not: false, range_operator: 'equal_to', activity_count: "1", since_date: Date.yesterday.strftime("%m/%d/%Y")}

        @verifier = Proc.new do |activity_type, expected_users|
          actual_users = ListCutter::MemberEmailActivityRule.new(options.merge(activity_type: activity_type, movement: @email.movement)).to_relation.all
          actual_users.should =~ expected_users
        end
      end

      it "should return the users with matching activity types" do
        email_sent_user, email_viewed_user, email_clicked_user, subscribed_user = create_list(:user, 4, movement: @email.movement)

        Push.log_activity!(UserActivityEvent::Activity::EMAIL_SENT, email_sent_user, @email)
        Push.log_activity!(UserActivityEvent::Activity::EMAIL_VIEWED, email_viewed_user, @email)
        Push.log_activity!(UserActivityEvent::Activity::EMAIL_CLICKED, email_clicked_user, @email)

        @verifier.call(UserActivityEvent::Activity::EMAIL_SENT, [email_sent_user])
        @verifier.call(UserActivityEvent::Activity::EMAIL_VIEWED, [email_viewed_user])
        @verifier.call(UserActivityEvent::Activity::EMAIL_CLICKED, [email_clicked_user])
      end
    end

    describe "operator with activity_count" do
      before(:each) do
        @email1 = create(:email)
        @movement = @email1.movement
        @email2 = create(:email, movement: @movement)
        @user_with_0_events, @user_with_1_event, @user_with_2_events = create_list(:user, 3, movement: @movement)
        @email_sent_event = UserActivityEvent::Activity::EMAIL_SENT
        options = {activity_type: @email_sent_event, since_date: Date.yesterday.strftime("%m/%d/%Y")}

        Push.log_activity!(@email_sent_event, @user_with_1_event, @email1)
        Push.log_activity!(@email_sent_event, @user_with_2_events, @email1)
        Push.log_activity!(@email_sent_event, @user_with_2_events, @email2)

        @verifier = Proc.new do |range_operator, activity_count, expected_users|
          actual_users = ListCutter::MemberEmailActivityRule.new(options.merge(
            range_operator: range_operator, 
            activity_count: activity_count,
            movement: @movement
          )).to_relation.all

          actual_users.should =~ expected_users
        end
      end

      it "should return the users with matching range operator" do
        @verifier.call('more_than', 2, [])
        @verifier.call('equal_to', 2, [@user_with_2_events])
        @verifier.call('less_than', 2, [@user_with_1_event, @user_with_0_events])

        @verifier.call('more_than', 1, [@user_with_2_events])
        @verifier.call('equal_to', 1, [@user_with_1_event])
        @verifier.call('less_than', 1, [@user_with_0_events])

        @verifier.call('more_than', 0, [@user_with_1_event, @user_with_2_events])
        @verifier.call('equal_to', 0, [@user_with_0_events])
        @verifier.call('less_than', 0, [])
      end

      it "should consider the users who have taken other actions" do
        user = create(:user, movement: @movement)
        email_clicked_event = UserActivityEvent::Activity::EMAIL_CLICKED

        Push.log_activity!(email_clicked_event, user, @email1)

        actual_users = ListCutter::MemberEmailActivityRule.new(
          activity_type: @email_sent_event, 
          range_operator: 'equal_to', 
          activity_count: 0,
          since_date: Date.yesterday.strftime("%m/%d/%Y"),
          movement: @movement
        ).to_relation.all

        actual_users.should =~ [@user_with_0_events, user]
      end
    end

    describe "since_date" do
      let(:today)                 { "10/12/2012" }
      let(:yesterday)             { "10/11/2012" }
      let(:day_before_yesterday)  { "10/10/2012" }
      let(:now)           { "2012-10-12 20:00:00" }
      let(:one_hour_ago)  { "2012-10-12 19:00:00" }
      let(:one_day_ago)   { "2012-10-11 20:00:00" }
      let(:two_days_ago)  { "2012-10-10 20:00:00" }
      let(:movement) { create :movement }
      let(:email) { create :email, movement: movement }
      let(:user_with_event_2_days_back) { create :user, movement: movement }
      let(:user_with_event_1_day_back) { create :user, movement: movement }
      let(:user_with_today_event) { create :user, movement: movement }

      before(:each) do
        options = {not: false, activity_type: UserActivityEvent::Activity::EMAIL_SENT, range_operator: "equal_to", activity_count: "1"}
        activities_table = "push_sent_emails"
        insert_sql = "INSERT INTO #{activities_table} (movement_id, user_id, email_id, created_at, push_id) VALUES "
        values = ["(#{movement.id}, #{user_with_today_event.id}, #{email.id}, '#{one_hour_ago}', 1)",
          "(#{movement.id}, #{user_with_event_1_day_back.id}, #{email.id}, '#{one_day_ago}', 1)",
          "(#{movement.id}, #{user_with_event_2_days_back.id}, #{email.id}, '#{two_days_ago}', 1)"]
          sql = insert_sql + values.join(',')
          ActiveRecord::Base.connection.execute(sql)

          @verifier = Proc.new do |since_date, expected_users|
            actual_users = ListCutter::MemberEmailActivityRule.new(options.merge(since_date: since_date, movement: email.movement)).to_relation.all
            actual_users.should =~ expected_users
          end
      end

      it 'finds the users that have any events today' do
        @verifier.call(today, [user_with_today_event])
      end
      it 'finds the users that have any events since yesterday' do
        @verifier.call(yesterday, [user_with_today_event, user_with_event_1_day_back])
      end
      it 'finds the users that have any events since two days ago' do
        @verifier.call(day_before_yesterday, [user_with_today_event, user_with_event_1_day_back, user_with_event_2_days_back])
      end
    end
  end

  describe "to_human_sql" do
    it "should return human readable form of conditions" do
      options = {since_date: "12/12/2012"}
      ListCutter::MemberEmailActivityRule.new(options.merge(not: false, range_operator: "more_than", activity_count: 2, activity_type: UserActivityEvent::Activity::EMAIL_SENT.to_s)).to_human_sql.should == "Member Email Activity is More Than 2 emails Sent since 12/12/2012"
      ListCutter::MemberEmailActivityRule.new(options.merge(not: true, range_operator: "more_than", activity_count: 2, activity_type: UserActivityEvent::Activity::EMAIL_SENT.to_s)).to_human_sql.should == "Member Email Activity is not More Than 2 emails Sent since 12/12/2012"
      ListCutter::MemberEmailActivityRule.new(options.merge(not: false, range_operator: "less_than", activity_count: 2, activity_type: UserActivityEvent::Activity::EMAIL_VIEWED.to_s)).to_human_sql.should == "Member Email Activity is Less Than 2 emails Opened since 12/12/2012"
      ListCutter::MemberEmailActivityRule.new(options.merge(not: true, range_operator: "equal_to", activity_count: 2, activity_type: UserActivityEvent::Activity::EMAIL_CLICKED.to_s)).to_human_sql.should == "Member Email Activity is not Equal To 2 emails Clicked since 12/12/2012"
    end
  end
end
