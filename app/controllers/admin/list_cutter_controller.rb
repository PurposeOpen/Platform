module Admin
  class ListCutterController < AdminController
    layout 'movements'
    self.nav_category = :campaigns

    def new
      @blast = Blast.find_by_id(params[:blast_id])
      @list = @blast.try(:list) || List.new(blast: @blast)
    end

    def edit
      @list = List.find(params[:list_id])
    end

    def count
      build_list_and_create_bg_job(save: false)
    end

    def save
      @list = List.build(params)
      head :unprocessable_entity and return unless @list.list_cuttable?
      build_list_and_create_bg_job(save: true)
    end

    def poll
      intermediate_result = ListIntermediateResult.find(params[:result_id])
      return head(:no_content) unless intermediate_result.ready?
      render :partial => 'admin/list_cutter/poll_summary', :locals => {:summary => intermediate_result.summary}
    end

    def show
      @list = List.find(params[:list_id])
      render :layout => false
    end

    private

    def build_list_and_create_bg_job(options = {})
      @list ||= List.build(params)
      new =  @list.new_record?
      (render(:json => @list.errors.to_json, :status => :unprocessable_entity) and return) unless @list.valid?
      @intermediate_result = ListIntermediateResult.create(list: @list, rules: @list.rules)
      @list.update_attributes(:saved_intermediate_result => @intermediate_result) if options[:save]
      @intermediate_result.delay(:queue => QueueConfigs::LIST_CUTTER_BLASTER_QUEUE).update_results!

      if (!options[:save] && new)
        @list.update_attributes(:rules => [])
        @list = List.find(@list.id)
      end
      render :json => {:intermediate_result_id => @intermediate_result.id, :list_id => @list.id}
    end

  end
end
