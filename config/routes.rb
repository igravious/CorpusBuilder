CorpusBuilder::Application.routes.draw do
  resources :units do
		collection do
			get 'by_dictionary/:id', to: 'units#by_dictionary', as: 'by_dictionary'
			get 'by_dictionary/:id/what', to: 'units#what', as: 'what'
		end
	end

  resources :entries

  resources :dictionaries do
		member do
			get 'entry'
		end
		collection do
			get 'compare'
		end
	end

  resources :resources

  # get 'files/uncached' => 'files#index', as: :uncached
  # get 'files/cached' => 'files#index', as: :cached
  resources :files, as: 'fyles' do
		member do
			patch 'cache'
			get 'local'
			get 'strip'
			get 'query'
		end
		collection do
			get 'uncached'
			get 'cached'
			get 'unlinked'
			get 'linked'
		end
	end
	# get 'files/:id', to: 'fyles#foo', constraints: { id: /[A-Z]\d{5}/ }, defaults: { format: 'txt' }
	# treats :id_local as all one thing rather than :id and _local
	# get 'files/:id_local', to: 'fyles#plain', constraints: { id: /\d{3}/ }, defaults: { format: 'txt' }, as: 'plain_fyle'
	# defaults: { format: 'foo' } not only does not seem to work but blocks format: foo in url_helper
	# get 'files/:id', to: 'fyles#plain', id: /\d{3}/ , defaults: { format: 'txt' }, as: 'plain_fyle'
	get 'snapshots/:n/:id-local', to: 'fyles#snapshotted', id: /\d{3}/, as: 'snapshot_fyle'
	get 'files/:id-local', to: 'fyles#plained', id: /\d{3}/, as: 'plain_fyle'
	get 'files/:id-local_part:chunk', to: 'fyles#chunked', id: /\d{3}/, chunk: /\d/, as: 'chunk_fyle'
	#	patch 'files/:id/cache' => 'files#cache'
	
	# oh, this pattern again
	get 'info' => 'pages#info'
	get 'philosoraptor' => 'pages#philosoraptor'
	get 'landing' => 'pages#landing'
	get 'inquiry' => 'pages#inquiry'
	get 'collect' => 'pages#collect' 	# collections of philosophical texts - uh ??
	get 'springy' => 'pages#springy'						# taxonomic
	get 'semantic-web' => 'pages#semantic_web'	# taxonomic
	get 'dracula' => 'pages#dracula'						# taxonomic

	post 'Ctrl-C-Poetry' => 'pages#do_pome', as: 'do_pome'
	 get 'Ctrl-C-Poetry' => 'pages#pome'   , as: 'pome'

	post 'paper' => 'pages#do_paper', as: 'do_paper'
	 get 'paper' => 'pages#paper'   , as: 'paper'

 #post 'search' => 'pages#do_search', as: 'do_search'		# use elasticsearch to search for terms in shapshot n
	 get 'search' => 'pages#search'   , as: 'search'			# use elasticsearch to search for terms in shapshot n

  resources :writings

  resources :links

  resources :texts do
		collection do
			get 'excluded'
			get 'included'
		end
		get 'from_file', on: :member # TODO rename to ?? (from_file_text_path from_file_new ??)
	end

	# get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
	# get '/:username', to: 'users#show'
  resources :authors do
		# surely be to jesus
		post 'dbpedia', on: :collection, action: :create_dbpedia
		get 'new/dbpedia', on: :collection, controller: :authors, action: :new_dbpedia # new via dbpedia
		get 'new/resource', on: :collection, controller: :authors, action: :new_resource # new via resource
		get 'metadata', on: :member, controller: :authors, action: :show_metadata
		# get 'from_dbpedia', on: :member
	end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
	# rails/info/properties doesn't show on a subdir?
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
