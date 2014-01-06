require 'resque/server'

PurposePlatform::Application.routes.draw do


  devise_for :users
  devise_for :platform_users



  resque_constraint = lambda do |request|
    request.env['warden'].authenticate!({ :scope => :platform_user })
  end
  constraints resque_constraint do
    mount Resque::Server, :at => "/admin/resque"
  end

  namespace :admin do
    root :to => "movements#index"

    resources :movements, :except => [:destroy] do
      get 'quick_go' => "quick_go#index"
      resources :images
      resources :downloadable_assets
      resource :homepages do
        put :create_preview
        get :preview
      end
      resources :campaigns do
        member do
          get :ask_stats_report
          get :pushes_for_combo
        end
      end

      resources :action_sequences do
        member do
          put :sort_pages
          put :toggle_published_status
          put :toggle_enabled_language
          post :duplicate
          get :preview
        end
        resources :user_activity_events, :only => [:index]
      end

      resources :action_pages do
        member do
          get :unlink_content_module
          get :validate_html
          put :create_preview
          get :preview
        end
      end

      resources :content_pages do
        member do
          put :create_preview
          get :preview
        end
      end

      resources :content_modules do
        member do
          post :create
          post :create_links_to_existing_modules
          delete :delete
          put :sort
        end
      end

      resources :featured_content_collections, :except => [:destroy, :create, :new]

      resources :featured_content_modules do
        member do
          put :sort
        end
      end

      resources :pushes do
        member do
          get :email_stats_report
          get :emails_for_combo
        end
      end

      resources :blasts do
        member do
          post :deliver
        end
      end

      resources :emails do
        get :clone
        post :cancel_schedule
      end

      resources :users

      namespace :reporting do
        resources :provider_domains
      end

      namespace :reporting do
        resources :deliverabilities
      end

      resources :join_emails, :only => [:index]
      post "join_emails" => "join_emails#update"
      resources :email_footers, :only => [:index]
      post "email_footers" => "email_footers#update"

      get "list_cutter/new" => "list_cutter#new"
      get "list_cutter/edit" => "list_cutter#edit"
      get "list_cutter/show" => "list_cutter#show"
      get "list_cutter/poll" => "list_cutter#poll"
      post "list_cutter/count" => "list_cutter#count"
      post "list_cutter/save" => "list_cutter#save"
      put "list_cutter/update" => "list_cutter#update"
    end
  end

  scope 'api', :module => "api" do

    post 'utility/unsubscribe_permanently' => "utility#unsubscribe_permanently"

    scope "/:locale", :locale => /(..){1}/ do
      match 'movements/:movement_id' => 'movements#show'

      scope 'movements/:movement_id' do
        resources :content_pages, :only => [:show] do
          member do
            get 'preview'
          end
        end
        resource  :activity, :only => [:show]
        resources :action_pages, :only => [:show] do
          member do
            get  'member_fields'
            post 'take_action'
            get 'preview'
            get 'share_counts'
          end
        end
      end
    end

    scope 'movements/:movement_id' do
      get "awesomeness(.:format)" => "health_dashboard#index", :as => 'awesomeness_dashboard'
      post 'sendgrid_event_handler' => 'sendgrid#event_handler'

      resources :members, :only => [:create]
      get 'members' => 'members#show'
      get 'members/member_info' => "members#member_info"
      resources :shares, :only => [:create]

      get 'email_tracking/email_opened' => "email_tracking#email_opened"
      post 'email_tracking/email_clicked' => "email_tracking#email_clicked"

      post 'action_pages/:id/donation_payment_error' => 'action_pages#donation_payment_error'

      get 'donations' => 'donations#show'
      post 'donations/add_payment' => "donations#add_payment"
      post 'donations/confirm_payment' => "donations#confirm_payment"
      post 'donations/create_spreedly_payment_method_and_purchase' => "donations#create_spreedly_payment_method_and_purchase"
      post 'donations/handle_failed_payment' => "donations#handle_failed_payment"
    end
  end

  # Friendly_ID URLs for all campaign/static pages.
  match "(/campaigns/:campaign_id)/:action_sequence_id(/:id)" => "action_pages#show", :as => "page"

  root :to => "admin/movements#index"
end
