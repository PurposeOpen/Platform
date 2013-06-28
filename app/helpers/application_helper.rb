module ApplicationHelper
  def include_addthis
    javascript_include_tag("#{request.protocol}s7.addthis.com/js/250/addthis_widget.js#username=")
  end

  def minimum_blast_schedule_time
    (Time.now.utc + AppConstants.blast_job_delay).strftime("%Y/%m/%d %H:%M:%S")
  end

  def now
    Time.now.utc.strftime("%Y/%m/%d %H:%M:%S")
  end
  
  def form_errors(subject)
    render :partial => "common/form_errors", :locals => {:subject => subject}
  end
  
  def friendly_path(page)
    campaign_id = page.action_sequence.campaign ? page.action_sequence.campaign.friendly_id : nil
    page_path(campaign_id, page.action_sequence.friendly_id, page.friendly_id)
  end
  
  def friendly_url(page)
    campaign_id = page.action_sequence.campaign ? page.action_sequence.campaign.friendly_id : nil
    page_url(campaign_id, page.action_sequence.friendly_id, page.friendly_id)
  end
  
  def word_truncate(text, length = 30, truncate_string = "...")
    return if text.nil?
    l = length - truncate_string.length
    text.length > length ? text[/\A.{#{l}}\w*\;?/m][/.*[\w\;]/m] + truncate_string : text
  end

  def sum_list objects, m
    objects.inject(0) { |acc, t| acc += t.send(m); acc }
  end

  def javascript_external_dependencies
    if Rails.env.production? || Rails.env.staging?
      %w(
        //ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js
        //ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js
        //www.google.com/jsapi
      )
    else
      %w(
        a-jquery.min
        b-jquery-ui.min
        google.jsapi.js
      )
    end
  end

  def navbar_item(key, title, opts={})
    opts.assert_valid_keys :path, :icon, :requires_auth, :auth_key
    path = opts[:path] || "#"
    is_active  = controller.active_nav?(key)

    content_tag :li, :class => is_active ? "active" : "" do
      link_to(path) { content_tag(:i, "", class: "icon icon-#{opts[:icon]}") + title }
    end
  end

  def navbar_header(name, opts={})
    content_tag :li, class: "header" do
      name.html_safe
    end
  end


  def navbar_header_movement(name,can_create_movement)
    content_tag :li, class: "header" do
      content_tag :div do
        content = content_tag :div , class:"movement-header" do name.html_safe end
        if can_create_movement
          content += content_tag :div, class:"movement-header-right" do
            link_to( icon("plus") + "New", new_admin_movement_path,:class => "new-movement-link" )
          end
        end
        content
      end
    end
  end

  def numerical_table_value(row, column)
    content_tag :td, :class => "numerical" do
      content_tag(:p, row[column], :class => "value") +
      content_tag(:p, row["#{column} Percentage"], :class => "percent")
    end
  end

  def email_stats_table(stats_table)
    if stats_table.full_rows.present?
      
    end
  end

  def visible_if(condition)
    condition ? '' : 'style="display: none"'.html_safe
  end

  def error_class_if_invalid(entity, field = nil)
    entity.valid?
    if field.present?
      entity.errors.messages[field].present? ? "error" : ""
    else
      entity.errors.present? ? "error" : ""
    end
  end

  def search_form(path, opts={})
    placeholder = opts[:placeholder] || "Search"
    form_tag(path, :method => :get) do
      text_field_tag(:query, params[:query], type: "search", class: "query", placeholder: placeholder) +
      button_tag(icon("search"), class: "button", type: "submit", id:"search_button")
    end
  end

  def page_header(title, opts={}, &block)
    content_tag :div, class: "page_header" do
      action_content = block_given? ? content_tag(:div, capture(&block), class: "actions") : ""
      search_content = opts[:search] ? search_form(opts[:search]) : ""
      content_tag(:h1, title) + search_content + action_content
    end
  end

  def icon(type)
    content_tag(:i, "", class: "icon icon-#{type}")
  end

  def history_of(entity)
    byline = (entity.respond_to?(:created_by) && !entity.created_by.blank?) ? " by #{entity.created_by}" : ""
    result = []

    if entity.respond_to?(:created_at) && entity.created_at
      create_time = content_tag(:span, time_ago_in_words(entity.created_at), class: "time", title: entity.created_at.to_s(:long))
      result << "Created " + create_time + byline + "."
    end

    if entity.respond_to?(:updated_at) && entity.updated_at
      update_time = content_tag(:span, time_ago_in_words(entity.updated_at), class: "time", title: entity.updated_at.to_s(:long))
      result << "Updated " + update_time + byline + "."
    end

    result.join(" ").html_safe
  end
end
