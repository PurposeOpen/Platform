module Admin
  module CrudActions
    def self.included(controller)
      controller.class_attribute :model_class, :model_name, :parent_model_class, :parent_model_name, :before_save_hook
      controller.extend(ClassMethods)
    end

    module ClassMethods
      def crud_actions_for(model_class, options)
        before_filter :find_model, if: lambda { params[:id] }
        before_filter :find_parent

        self.model_class = model_class
        self.model_name  = "#{model_class.name.underscore}"
        if options[:parent]
          self.parent_model_class = options[:parent]
          self.parent_model_name  = "#{parent_model_class.name.underscore}"
        end
        if options[:before_save_hook]
          self.before_save_hook = options[:before_save_hook]
        end
        self.send(:include, Actions)
        define_method(:before_save_hook) { options[:before_save_hook]}
        define_method(:model) { instance_variable_get("@#{model_name}") }
        define_method(:model=) { |value| instance_variable_set("@#{model_name}", value) }
        define_method(:parent_model) { instance_variable_get("@#{parent_model_name}") }
        define_method(:parent_model=) { |value| instance_variable_set("@#{parent_model_name}", value) }
        define_method(:crud_redirect) { |key| instance_exec(&options[:redirects][key]) }
      end
    end

    module Actions
      def new
        if parent_model
          self.model = parent_model.send(model_name.pluralize).build
        else
          self.model = model_class.new
        end
      end

      def edit
      end

      def create
        if parent_model
          self.model = parent_model.send(model_name.pluralize).build(params[model_name])
        else
          self.model = model_class.new(params[model_name])
        end
        if before_save_hook
          before_save_hook.call(model)
        end
        if model.save
          redirect_to crud_redirect(:create), notice: "'#{model.name}' has been created."
        else
          flash[:error] = 'Your changes have NOT BEEN SAVED YET. Please fix the errors below.'
          render action: 'new'
        end
      end

      def update
        if before_save_hook
          before_save_hook.call(model)
        end
        if model.update_attributes(params[model_name])
          redirect_to crud_redirect(:update), notice: "'#{model.name}' has been updated."
        else
          flash[:error] = 'Your changes have NOT BEEN SAVED YET. Please fix the errors below.'
          render action: 'edit'
        end
      end

      def destroy
        model.destroy
        redirect_to crud_redirect(:destroy), notice: "'#{model.name}' has been deleted."
      end

      private

      def find_model
        if model_class.ancestors.include? Page
          self.model = @movement.find_page params[:id]
        else
          self.model = model_class.find(params[:id])
        end
      end

      def find_parent
        return unless parent_model_class
        if parent_id = params["#{parent_model_name}_id"]
          self.parent_model = parent_model_class.find(parent_id)
        else
          self.parent_model = model.send(parent_model_name)
        end
      end
    end
  end
end