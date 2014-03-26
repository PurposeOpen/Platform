module Admin
  module AdminHelper

    # TODO This is unsustainable. I recommend pushing these into individual views.
    def breadcrumbs
      return "" if @movement.nil?

      crumbs = []

      if @movement.new_record?
        crumbs << ["New Movement", new_admin_movement_path]
      else
        crumbs << [@movement.name, admin_movement_path(@movement)]
        crumbs << ["Home", admin_movement_path(@movement)] if controller.active_nav?(:home)
        crumbs << ["Edit Movement", edit_admin_movement_path(@movement)] if controller_and_action_name == 'movements_edit'
        crumbs << ["Edit Join Emails", admin_movement_join_emails_path(@movement)] if controller_and_action_name == 'join_emails_index'
        crumbs << ["Campaigns", admin_movement_campaigns_path(@movement)] if controller.active_nav?(:campaigns)
        crumbs << ["Content Pages", admin_movement_content_pages_path(@movement)] if controller.active_nav?(:content_pages)

        campaign = identify_campaign

        if campaign
          crumbs << [campaign.name, admin_movement_campaign_path(@movement, campaign)] unless campaign.new_record?

          if @action_sequence && !@action_sequence.new_record?
            crumbs << [@action_sequence.name, admin_movement_action_sequence_path(@movement, @action_sequence)]
          end

          if @action_page && !@action_page.new_record?
            crumbs << [@action_page.name, edit_admin_movement_action_page_path(@movement, @action_page)]
          end

          push = @push || @list.try(:blast).try(:push) || @email.try(:blast).try(:push)
          if push
            crumbs << [push.name, admin_movement_push_path(@movement, push)] unless push.new_record?
          end

          if @email && !@email.new_record?
            crumbs << [@email.display_name, edit_admin_movement_email_path(@movement, @email)]
          end

          if @list
            crumbs << [@list.blast.name, admin_movement_push_path(@movement, @list.blast.push)]
          end
        end

        if @content_page && !@content_page.new_record?
          crumbs << [@content_page.name, edit_admin_movement_content_page_path(@movement, @content_page)]
        end

        if @featured_pages || @featured_content_collection
          crumbs << ["Featured Contents", admin_movement_featured_content_collections_path(@movement)]
          if @featured_content_collection
              crumbs << [@featured_content_collection.name, edit_admin_movement_featured_content_collection_path(@movement, @featured_content_collection)]
          end
        end
      end

      crumbs_html = crumbs.collect do |crumb|
        link_to_unless_current(crumb.first, crumb.last)
      end * " &raquo; "
      crumbs_html.html_safe
    end

    def script_directionality(iso_code)
      ['ar', 'iw', 'fa', 'ur'].include?(iso_code) ? 'right-to-left' : 'left-to-right'
    end

    private

    def identify_campaign
      @campaign || @action_sequence.try(:campaign) || @push.try(:campaign) || (@list.nil? ? nil : @list.blast.push.campaign) || (@email.nil? ? nil : @email.blast.push.campaign)
    end

    def controller_and_action_name
      "#{controller.controller_name}_#{controller.action_name}"      
    end

    def version_string
      if ENV.has_key?("DEPLOYED_REVISION")
        ENV['DEPLOYED_REVISION']
      elsif Rails.env.development?
        `git rev-parse HEAD`
      else
        "Unknown version"
      end
    end
  end
end
