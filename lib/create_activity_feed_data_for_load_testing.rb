require 'uuid'

def create_activity_feed_data(users_per_movement)
  original_logger = ActiveRecord::Base.logger
  ActiveRecord::Base.logger = ::Logger.new(nil)
  ActiveRecord::Base.clear_all_connections!


  movements = Movement.all
  action_pages = ActionPage.all
  actions_per_page = {}
  action_pages.each {|page| actions_per_page[page] = 0}

  movements.each do |movement|
    default_language = movement.default_language
    movement_action_pages = action_pages.find_all {|p| p.movement.id == movement.id}

    start_time = Time.now.to_i

    users_per_movement.times do |time|

      action_info_for_donations = {
        :currency => :usd,
        :amount => 10000,
        :payment_method => :paypal,
        :order_id => UUID.generate.to_s,
        :transaction_id => UUID.generate.to_s
      }
      action_info_for_email_targets = {
        :cc_me => false,
        :subject => 'Email',
        :body => 'Hi!'
      }
      all_actions_info = action_info_for_donations.merge(action_info_for_email_targets)

      action_page = movement_action_pages[(rand * movement_action_pages.size).to_i]
      if action_page
        user = FactoryGirl.create(:user, :email => "fakedata#{start_time.to_s + time.to_s}@example.com", :movement => movement, :language => default_language)
        user.take_action_on!(action_page, all_actions_info)
        actions_per_page[action_page] += 1
      end
    end
  end

  actions_per_page.each do |action_page, user_count|
    if user_count > 0
      puts "Created #{user_count} user actions (and subscriptions) using page #{action_page.id}:'#{action_page.name}' (#{action_page.movement.name})"
    end
  end

  ActiveRecord::Base.logger = original_logger
end