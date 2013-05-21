module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def     path_to(page_name)
    case page_name

      when /the home\s?page/
        '/'

      # Add more mappings here.
      # Here is an example that pulls values out of the Regexp:
      #
      #   when /^(.*)'s profile page$/i
      #     user_profile_path(User.find_by_login($1))

      when /html page/
        'file:///home/pallavi/Downloads/1951.html'


      when /the dashboard/
        '/dashboard'

      when /My Target!/
        '/dashboard'

      when /^the admin downloadable assets page for the movement "(.*)"$/
        movement = Movement.find_last_by_name($1)
        admin_movement_downloadable_assets_path(movement)

      when /^the admin images page for the movement "(.*)"$/
        movement = Movement.find_last_by_name($1)
        admin_movement_images_path(movement)

      when /the unsubscribe me page/
        unsubscribe_path

      when /the admin new list page for "(.*?)"/
        push = Push.find_last_by_name($1)
        push.should_not be_nil
        admin_movement_list_cutter_new_path(push.campaign.movement)

      when /the admin campaign page for "(.*?)"/
        campaign = Campaign.find_last_by_name($1)
        admin_movement_campaign_path(campaign.movement, campaign)

      when /the public campaign page entitled "(.*?)"/
        page = ActionPage.find_last_by_name($1)
        page.should_not be_nil
        page_path(page)

      when /the admin action sequence page for "(.*?)"/
        action_sequence = ActionSequence.find_last_by_name($1)
        admin_movement_action_sequence_path(action_sequence.campaign.movement, action_sequence)

      when /the content editing page for "(.*?)"/
        page = ActionPage.find_last_by_name($1)
        page.should_not be_nil
        edit_admin_movement_action_page_path(page.action_sequence.campaign.movement, page)

      when /the admin push page for "(.*?)"/
        push = Push.find_last_by_name($1)
        push.should_not be_nil
        admin_movement_push_path(push.campaign.movement, push)

      when /the public static page "(.*)\/(.*)"/
        action_sequence_name, page_name = $1, $2
        page                          = ActionPage.find(:last, :conditions => ['lower(name) = ?', $2.downcase])
        page.should_not be_nil
        page.action_sequence.name.downcase.should == action_sequence_name
        "/#{page.action_sequence.name.downcase}/#{page.name.downcase}"

      #TODO #223 - Refactor after the member/platform user split is done
      when /the edit admin user page for "(.*?)" in "(.*?)"/
        movement = Movement.find_last_by_name($2)
        user = PlatformUser.find_by_email($1)
        user.should_not be_nil
        edit_admin_movement_user_path(movement, user)

      #TODO #223 - Refactor after the member/platform user split is done
      when /the select role page for "(.*?)" in "(.*?)"/
        movement = Movement.find_last_by_name($2)
        user = PlatformUser.find_by_email($1)
        [user,movement].each do |o| o.should_not be_nil end
        edit_admin_movement_movements_user_path(movement, user)

      when /the admin edit email page for "(.*?)"/
        email = Email.find_by_name($1)
        movement = email.blast.push.campaign.movement
        edit_admin_movement_email_path(movement, email)

      when /the edit admin donation page/
        donation = Donation.new
        edit_admin_donation_page(donation)

      when /the page with URL "(.*)"/
        $1

      when /the Get Togethers page/
        "/get_togethers"

      when /the admin get together page for "(.*)"/
        get_together = GetTogether.find_by_name($1)
        admin_get_together_path(get_together)

      when /the "(.*)" event page/
        event = Event.find_by_name($1)
        event_path(event.friendly_id)

      when /the "(.*)" get together page/
        get_together = GetTogether.find_by_name($1)
        get_together_path(get_together)

      when /the campaigns for "(.*)"/
        movement = Movement.find_last_by_name($1)
        admin_movement_campaigns_path(movement)

      when /the "(.*)" movement page/
        movement = Movement.find_last_by_name($1)
        admin_movement_path(movement)

      when /the "(.*)" edit movement page/
        movement = Movement.find_last_by_name($1)
        edit_admin_movement_path(movement)

      when /the "(.*)" admin campaigns page/
        movement = Movement.find_last_by_name($1)
        admin_movement_campaigns_path(movement)

      when /the "(.*)" admin content pages page/
        movement = Movement.find_last_by_name($1)
        admin_movement_content_pages_path(movement)

      when /platform login page/
        "/platform_users/sign_in"

      when /the "(.*)" users page/
        movement = $1
        "/admin/movements/#{movement}/users"

      else
        begin
          page_name =~ /the (.*) page/
          path_components = $1.split(/\s+/)
          self.send(path_components.push('path').join('_').to_sym)
        rescue Object => e
          raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
                    "Now, go and add a mapping in #{__FILE__}"
        end
    end
  end
end

World(NavigationHelpers)
