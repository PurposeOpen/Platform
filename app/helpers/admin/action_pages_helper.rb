module Admin::ActionPagesHelper
  def edit_content_module_partial(content_module)
    "admin/content_modules/content_module_types/#{content_module.class.name.underscore}"
  end

  def render_donation_module_partial(content_module, f)
    render :partial => 'admin/content_modules/content_module_types/donation_module',
        :locals => { :f => f, :content_module => content_module }
  end

  def add_content_module_link(page, module_type, container, text)
    link_to(text, admin_movement_content_module_path(@movement, :type => module_type, :container => container, :page_id => page.id, :page_type => page.class.name), :method => :post, :remote => true, :class => "button add-module-link #{module_type.name.underscore}")
  end

  def external_module_link(module_type, text)
    plural = module_type.name.pluralize.underscore
    link_to(text, "/admin/#{plural}", :class => "add-module-link #{plural}_module", :target => "_blank")
  end

  def disabled_class(content_module)
    content_module.can_remove_from_page? ? '' : 'disabled'
  end

  def action_page_type_radio(form, content_module_class = nil)
    radio_button_value = content_module_class ? content_module_class.name.underscore : ''
    label_text = content_module_class ? content_module_class.label : 'Blank'

    %{
      <div class='action_page_type'>
        #{form.radio_button :seeded_module, radio_button_value}
        #{form.label "seeded_module_#{radio_button_value}".to_sym, label_text, :class => "radio"}
      </div>
    }.html_safe
  end

  def default_currency_options
    DonationModule::AVAILABLE_CURRENCIES.collect do |key, currency|
      [currency.name, currency.iso_code.downcase]
    end.insert(0, ['Select Currency', nil, {:disabled => true, :selected => 'selected'} ])
  end

  def default_amount_options(suggested_amounts)
    suggested_amounts.try(:split, /\s*,\s*/) || []
  end

  def preselect_default_amount(default_amount, amount)
    is_default_amount = (default_amount == amount)
    {:checked => is_default_amount}
  end

  def currency_summary(currency)
    "#{currency.iso_code} - #{currency.name}"
  end

  def options_for_pages_with_counter(action_sequence)
    [['Select an Action Page', nil]] + action_sequence.action_pages_with_counter.map {|page| [page.name, page.id]}
  end

  def preview_url_for_action_sequence(language_iso_code, movement, page)
    movement_base_url = movement.url
    page.class == ActionPage ?  "#{movement_base_url}/#{language_iso_code}/actions/#{page.id}/preview" : "#{movement_base_url}/#{language_iso_code}/#{page.slug}/preview"
  end
end


