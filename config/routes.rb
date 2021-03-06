require 'sidekiq/web'
require 'sidekiq/cron/web'
Mpd::Application.routes.draw do

  resources :regions, :except => [:show]

  resources :periods, :shallow => true do
		member do
			get 'toggle_updated'
			post 'do_update'
		end

		resources :teams, :except => [:index, :new], :shallow => true do
			#resources :leaders, :as => 'team_leaders', :only => [:show, :create, :destroy]
			member do
				get 'list'
				post 'list'
			end
		end
		resources :groups, :except => [:index, :new], :shallow => true do
			resources :coaches, :as => 'group_coaches', :only => [:show, :create, :destroy]
			member do
				get 'list'
				post 'list'
			end
		end
		resources :admins, :as => 'period_admins', :only => [:show, :create, :destroy]
		member do
			get 'list'
			post 'list'
			get 'fields'
			post 'update_fields'
			get 'benchmarks'
			post 'update_benchmarks'
		end
	end

	resources :assignments, :except => :index, :shallow => true do
		resources :pledges, :only => [:index, :create, :destroy] do
			put 'toggle', :on => :member
		end
		resources :reports, :except => :index do
			collection do
				get 'list'
				post 'list'
			end
		end
		resources :goals
	end
  
  resources :users, :except => :index do
		get :confirm, :on => :member
		get :autocomplete, :on => :collection
		post :toggle_admin, :on => :member
		get :sudo, :on => :member
		get :unsudo, :on => :collection
	end

	match 'login' => 'home#login', :via => :get
	match 'login' => 'home#do_login', :via => :post
	match 'logout' => 'home#logout'
	match 'full_update' => 'home#full_update'
  match 'view_user' => 'home#view_user'
  match 'list' => 'home#list'
	
  # Shameless
  match 'backdoor' => 'home#backdoor'

  get 'monitors/lb' => 'monitors#lb'

	mount Sidekiq::Web => '/sidekiq'

	root :to => 'home#index'

	# Catch-all
	match '*uri' => 'home#not_found'
  
end
