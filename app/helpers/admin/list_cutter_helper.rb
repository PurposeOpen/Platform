module Admin::ListCutterHelper
  def rules_for_form
    [
        {label: "Country", class: ListCutter::CountryRule},
        {label: "Zone", class: ListCutter::ZoneRule},
        {label: "Domain", class: ListCutter::EmailDomainRule},
        {label: "Campaigns", class: ListCutter::CampaignRule},
        {label: "Action Page", class: ListCutter::ActionTakenRule},
        {label: "Email status", class: ListCutter::EmailActionRule},
        {label: "Join Date", class: ListCutter::JoinDateRule},
        {label: "Member Activity", class: ListCutter::MemberActivityRule},
        {label: "Source", class: ListCutter::MemberSourceRule},
        {label: "Originating Action", class: ListCutter::OriginatingActionRule},
        {label: "Member Email Activity", class: ListCutter::MemberEmailActivityRule},
        {label: "Donation frequency", class: ListCutter::DonorRule},
        {label: "Donation amount", class: ListCutter::DonationAmountRule},
        {label: "External Action", class: ListCutter::ExternalActionRule},
        {label: "External Tag", class: ListCutter::ExternalTagRule}
    ]
  end

  def error_for(model, key)
    model.errors[key].inject("") do |acc, msg|
      acc << "<span class=\"error\">#{msg}</span>"
    end
  end

  def get_rule(list, rule_class)
    list.rules.select { |r| r.class == rule_class }.first || rule_class.new
  end

  def electorate_select_options
    Electorate.all.inject({}) do |acc, e|
      acc[e.name] = e.id
      acc
    end
  end

  def grouped_select_options_emails(movement_id, selected)
    options = Rails.cache.fetch("/grouped_select_options_email/#{movement_id}") do
      store = Hash.new
      Campaign.joins(:movement).where("campaigns.movement_id = %d", movement_id).order("campaigns.updated_at desc").select("campaigns.id, campaigns.name").each {|campaign|
        campaign_blasts = Blast.joins(:push).where("pushes.campaign_id = #{campaign.id}")
        blasts_for_campaign = construct_group_options_hash(campaign_blasts, :emails, &nil)
        store[campaign.name] = blasts_for_campaign if !blasts_for_campaign.empty?
      }
      store
    end

    create_opt_groups(options, selected)
  end

  def grouped_select_options_pages(movement_id, selected)
    options = Rails.cache.fetch("/grouped_select_options_pages/#{movement_id}") do
      store = Hash.new
      Campaign.joins(:movement).where("campaigns.movement_id = %d", movement_id).order("campaigns.updated_at desc").select("campaigns.id, campaigns.name").each {|campaign|
        campaign_action_sequences = ActionSequence.joins(:campaign).where("action_sequences.campaign_id = %d", campaign.id)
        condition_for_inclusion = Proc.new{|action_page| (action_page.has_an_ask? && !action_page.is_unsubscribe? )}
        action_sequences_for_campaign = construct_group_options_hash(campaign_action_sequences, :action_pages, &condition_for_inclusion)
        store[campaign.name] = action_sequences_for_campaign if !action_sequences_for_campaign.empty?
      }
      store
    end

    create_opt_groups(options, selected)
  end

  def grouped_select_options_external_actions(movement_id, selected)
    options = Rails.cache.fetch("/grouped_select_options_external_actions/#{movement_id}") do
      fields = 'source, partner, action_slug'
      store = ExternalAction.where(movement_id: movement_id).select(fields + ', unique_action_slug').order(fields).map do |event|
                                      partner = event.partner.blank? ? '' : "#{event.partner.upcase} - "
                                      ["#{event.source.upcase}: #{partner}#{event.action_slug}", event.unique_action_slug]
                                    end
    end

    options_for_select(options, selected)
  end

  def select_options_action_pages(movement_id, selected)
    options = Rails.cache.fetch("/select_options_pages/#{movement_id}") do
      ActionPage.page_options(movement_id, ListCutter::OriginatingActionRule::POSSIBLE_MODULE_TYPES)
    end

    options_for_select(options, selected).gsub(/\n/, '').html_safe
  end

  def activity_options(selected)
    options = ExternalActivityEvent::ACTIVITIES.map { |activity| [activity.split("_")[1..-1].join(" ").titleize, activity] }
    options_for_select(options, selected)
  end

  def filter_selected?(rule, rule_option)
    rule.class == rule_option[:class] ? "selected='selected'".html_safe : ""
  end

  def member_activity_select_options
    UserActivityEvent::Activity.constants.map do |activity_type|
      [activity_type, UserActivityEvent::Activity.const_get(activity_type)]
    end
  end

  private
  def construct_group_options_hash(values_for_opt_groups, value_for_options, &include_condition )
    hash = {}
    values_for_opt_groups.each { |value|
      options = []
      value.send(value_for_options).each { |option_val|
        options << [option_val.name, option_val.id] if (include_condition.nil? || include_condition.call(option_val))
      }
      next if options.size == 0
      map_from_hash = hash[value.name]
      if (map_from_hash)
        hash[value.name] = map_from_hash + options
      else
        hash[value.name] = options
      end
    }
    hash
  end

  def create_opt_groups(store, selected)
    new_select_options = ''
    store.keys.each { |key|
      new_select_options += "<optgroup label=\"#{key}\" parent-group=\"true\"></optgroup>"
      new_select_options += create_group_options(store[key], selected)
    }
    new_select_options.gsub(/\n/, '').html_safe
  end

  def create_group_options(grouped_options, selected_key)
    body = ''
    grouped_options.sort.each do |group|
      body << content_tag(:optgroup, options_for_select(group[1], selected_key), label: group[0], id: SecureRandom.uuid)
    end
    body.html_safe
  end

  def grouped_select_options_external_tags movement_id, selected
    options = Rails.cache.fetch("/grouped_select_options_external_tags/#{movement_id}") do
      ExternalTag.where(movement_id: movement_id).map {|tag| tag.name}
    end

    options_for_select(options, selected)
  end
end
