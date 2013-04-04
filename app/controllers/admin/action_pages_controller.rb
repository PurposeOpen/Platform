module Admin
  class ActionPagesController < AdminController
    layout 'movements'
    self.nav_category = :campaigns
    include ActionView::Helpers::TextHelper

    crud_actions_for ActionPage, :parent => ActionSequence, :redirects => {
      :create  => lambda { admin_movement_action_sequence_path(@movement, @action_sequence) },
      :destroy => lambda { admin_movement_action_sequence_path(@movement, @action_sequence) }
    }

    skip_before_filter  :find_model, only: [:preview]
    skip_before_filter  :find_parent, only: [:preview]

    before_filter :find_content_modules, :except => [:new, :create, :preview]
    cache_sweeper PageSweeper

    def edit
      @action_page.set_up_autofire_emails
    end

    def update
      page_updated = @action_page.update_attributes(params[:action_page])
      update_results = UpdateResults.new
      update_content_modules(params[:content_modules], update_results)
      update_autofire_emails(params[:autofire_emails], update_results)
      ActionPageObserver.update(@action_page)
      if update_results.has_reports?
        flash.now[:notice] = update_results.success_message if update_results.has_success?
        flash.now[:info]   = update_results.failure_message if update_results.has_failures?
        render :action => 'edit'
      else
        redirect_to admin_movement_action_sequence_path(@movement, @action_sequence), :notice => "'#{@action_page.name}' has been updated."
      end
    end

    def create_preview
      cloned_action_page = @action_page.dup
      cloned_action_page.position = nil
      cloned_action_page.live_page_id = @action_page.id
      cloned_action_page.save
      clone_content_modules_for_preview(params[:content_modules], cloned_action_page)
      clone_autofire_emails_for_preview(params[:autofire_emails], cloned_action_page)
      render :text =>  preview_admin_movement_action_page_path(@movement, cloned_action_page)
    end

    def preview
      @movement = Movement.find params[:movement_id]
      @action_page = @movement.find_page_unscoped(params[:id])
      @action_sequence = @action_page.action_sequence
      @action_pages = @action_sequence.action_pages
      @live_action_page = @action_page.live_action_page
      @action_pages[@action_pages.find_index(@live_action_page)] = @action_page
      render :layout => '_base'
    end

    def unlink_content_module
       link = ContentModuleLink.where(:page_id => @action_page.id, :content_module_id => params[:content_module_id]).first
       link.content_module = link.content_module.dup
       link.save!
       respond_to do |format|
         format.js { render :content_type => 'text/html', :partial => 'content_module', :locals => {:content_module => link.content_module, :layout_container => link.layout_container} }
       end
    end

    private

    def find_content_modules
      @header_content_modules = @action_page.header_content_modules
      @main_content_modules = @action_page.main_content_modules
      @sidebar_content_modules = @action_page.sidebar_content_modules
      @footer_content_modules = @action_page.footer_content_modules
    end

    def update_content_modules(updated_attrs, update_results)
      return unless updated_attrs
      all_modules = @header_content_modules + @main_content_modules + @sidebar_content_modules + @footer_content_modules
      updated_attrs.each do |id, attrs|
        content_module = all_modules.find { |cm| cm.id == id.to_i }
        content_module.update_attributes(attrs)
        if content_module.valid_with_warnings?
          update_results.report_success_for content_module.language.name
        else
          update_results.report_failure_for content_module.language.name
        end
      end
    end

    def clone_content_modules_for_preview(updated_attrs, cloned_action_page)
      return unless updated_attrs
      updated_attrs.each do |id, attrs|
        content_module = ContentModule.find id
        moduleLinks = ContentModuleLink.where(:page_id => @action_page.id, :content_module_id => id)
        cloned_content_module = content_module.dup
        cloned_content_module.live_content_module_id = content_module.id
        cloned_content_module.update_attributes(attrs)
        moduleLinks.each do |cml|
          cloned_cml = cml.dup
          cloned_cml.page_id = cloned_action_page.id
          cloned_cml.content_module = cloned_content_module
          cloned_cml.save
        end
      end
    end

    def clone_autofire_emails_for_preview(attrs,  cloned_action_page)
      return unless attrs
      attrs.each_value do |hash|
        autofire_email = AutofireEmail.find(hash['id']).dup
        autofire_email.action_page = cloned_action_page
        update_autofire_email(autofire_email, hash)
        autofire_email.save
      end
    end

    def update_autofire_emails(attrs, update_results)
      return unless attrs
      attrs.each_value do |hash|
        autofire_email = AutofireEmail.find(hash['id'])
        update_autofire_email(autofire_email, hash)
        if autofire_email.valid_with_warnings?
          update_results.report_success_for autofire_email.language.name
        else
          update_results.report_failure_for autofire_email.language.name
        end
      end
    end

    def update_autofire_email(autofire_email, hash)
      autofire_email.update_attributes(:enabled => hash['enabled'], :subject => hash['subject'],
                                       :body => hash['body'], :from => hash['from'], :reply_to => hash['reply_to'])
    end
  end



  class UpdateResults
    def initialize; @success, @failure = Set.new, Set.new end
    def has_success?; @success.any? end
    def has_failures?; @failure.any? end
    def has_reports?; has_success? || has_failures? end
    def report_success_for language_name
      @success.add language_name unless @failure.include?(language_name)
    end
    def report_failure_for language_name
      @success.delete language_name
      @failure.add language_name
    end
    def success_message
      "The following languages were completely updated:<br><br>- #{@success.to_a.join('<br>- ')}" unless @success.empty?
    end
    def failure_message
      "The following languages were updated but still have warnings:<br><br>- #{@failure.to_a.join('<br>- ')}" unless @failure.empty?
    end
  end
end
