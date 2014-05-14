module Admin
  class ActionSequencesController < AdminController
    layout 'movements'
    self.nav_category = :campaigns

    crud_actions_for ActionSequence, parent: Campaign, redirects: {
      create:  lambda { admin_movement_action_sequence_path(@movement, @action_sequence) },
      update:  lambda { admin_movement_action_sequence_path(@movement, @action_sequence) },
      destroy: lambda { admin_movement_campaign_path(@movement, @campaign) }
    }

    def toggle_published_status
      @action_sequence.update_attribute('published', params[:published] == 'true')
      head :ok
    end

    def toggle_enabled_language
      language = Language.find_by_iso_code(params['iso_code'])
      enabled = params[:enabled] == 'true'
      if enabled
        @action_sequence.enable_language language
      else
        @action_sequence.disable_language language
      end
      @action_sequence.save!

      head :ok
    end

    def sort_pages
      @action_sequence.action_pages.each do |page|
        page.update_attribute(:position, params[:page].index(page.id.to_s) + 1)
      end
      render nothing: true
    end
    
    def duplicate
      new_sequence = @action_sequence.duplicate
      new_sequence.save!
      redirect_to admin_movement_campaign_path(@movement, @campaign), notice: "'#{@action_sequence.name}' has been duplicated."
    end

    def preview
      @language = Language.find_by_iso_code(params['iso_code'])
      @action_pages = @action_sequence.action_pages
      render layout: '_base'
    end
  end
end