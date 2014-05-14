module Admin
  class QuickGoController < AdminController
    def index
      term = params[:term]
      movement_id = @movement.id
      search = Sunspot.search [ActionSequence, Campaign, ContentPage, Email, Push, ActionPage] do
        fulltext term
        with :movement_id, movement_id
        paginate page: 1, per_page: 15
      end
      render json: search.hits.collect {|x| form_suggestion(x)}
    end

    private

    def form_suggestion(item)
      to_edit = ['ContentPage', 'ActionPage', 'Email'].include?(item.class_name)
      {name: item.stored(:name), type: item.class_name, path: polymorphic_path([(:edit if to_edit), :admin, @movement, item.class_name.underscore], {id: item.stored(:to_param)})}
    end
  end
end
