Stak-Framework
=============

A flexible, minimal, MVC web-application framework.

[![Gem Version](https://badge.fury.io/rb/stak.svg)](http://badge.fury.io/rb/stak)

To use Stak, simply inherit from `Stak::Application`:

	require 'stak'

	module StakExample
		class Application < Stak::Application
		end
	end

Provide a `config.ru` in the root directory containing your app:

	app = StakExample::Application.new
	app.router.config do
	# Custom Routes Here
	end

	# Middleware Here
	run app

### Philosophy

Stak combines the control and customizability of a lightweight framework with the convenience of a convention-driven MVC paradigm.  Simplicity is the guide, and Stak is just 300 lines of code.  Above all, the design principles are:

1. Don't repeat yourself
2. Just Rack, and nothing else
3. Minimal, unassuming, and extensible

### Models

Stak runs on top of SQLite3.  Models inherit from `Stak::Mapper`, which gives them all the standard record-handling methods, including `new`, `save`, `update`, `find`, `first`, `last`, `all`, and `destroy`.  Model names and attributes are mapped to database tables and columns, like so:

	class Article < Stak::Mapper
		attr_accessor :body, :tagline, :submitter, :created_at
		
		@@table = 'articles'

		@@mappings.draw(
			content: :body,
			tagline: :tagline,
			submitter: :submitter,
			created_at: :created_at
		)

		# Custom Methods Here
	end

### Migrations

Since models are implemented in SQLite3, a Ruby-based parser or wrapper around database migrations is unnecessary.  Migrations can be handled directly in the database.  For example, a `create_articles.rb` migration simply involves a corresponding statement, like so:

	require 'sqlite3'

	db = SQLite3::Database.new File.join('db', 'app.db')

	db.execute(
		"
			CREATE TABLE articles (
				id integer primary key,
				content text,
				tagline varchar(250),
				submitter varchar(250),
				created_at datetime default null
			)
		"
	)

### Controllers

Stak provides a minimal interface between default routes and standard CRUD actions.  Controllers inherit from `Stak::Controller`, which grants automatic routing for `index`, `new`, `create`, `show`, `edit`, `update`, and `delete` actions.  Stak requires the use of strong parameters.  For instance:

	class ArticlesController < Stak::Controller
		# Custom Actions Here

		def create
			@article = Article.new(article_params)
			@article.save

			redirect action: :show, id: Article.last.id
		end

		private
		
			def article_params
				params[:article].permit(:body, :tagline, :submitter)
			end
	end
	
### Views

Stak uses [Erubis](http://www.kuwata-lab.com/erubis/) to render views, and provides for the use of default and custom templates.  Partials are rendered within layouts with the tag `<%= insert %>`.  Views are rendered with instance variables automatically passed along, which take precedence over any local variables specified:

	def sample
		@ua = request.user_agent
		@noun = 'winking'
		render :sample, locals: { a_local: :roar, ua: 'overridden' }, layout: false
	end
	
Redirections behave as expected:

	def delete
		article = Article.find(params[:id])
		article.destroy

		redirect action: :index
	end
	
### Routing

Stak implements the standard MVC resource model, providing default routes for CRUD actions.  For example a `GET` request at `/articles/3/show` attempts to call the `show` method in the `ArticlesController` class, and also attempts to render the `show.html.erb` view.  Resources are declared like so:

	resources :articles
	
Custom routes are defined within the `config` block.  Stak supports all HTTP verbs `delete`, `get`, `head`, `options`, `patch`, `post`, and `put`.  Routes can be defined with query and route parameters, and can make a direct call to a controller action, as follows:

	get '/index', 'articles#index'

	get '/params/:foo/with/target/:fooz', 'articles#sample'
	
Alternatively, routes can be defined in block format, in which case the route definition follows an identical convention to controller action definitions.  Where default Stak resource routes conflict with user-defined custom routes, custom routes take precedence.  For example:

	get '/params/:foo/with/block/:fooz' do
		@ua = request.user_agent
		@noun = 'winking'
		render 'articles/sample', locals: { a_local: :roar, ua: 'overridden' }, layout: false
	end

### Middleware

A Stak app is Rack-compatible.  As such, Stak supports the use of Rack middleware.  Any `use` statements located before the call to the Stak app in `config.ru` are treated as middleware, with sequential middleware layered in the order specified, like so:

	use Rack::MethodOverride
	use Rack::Static, :urls => ['/css'], :root => 'public'
	run app
	
A Stak app itself can also be used inside any other Rack-based app:

	class MyApp < Sinatra::Base
		use StakExample
	end
	
### Resources

* [RubyGems](https://rubygems.org/)
* [Documentation](http://www.rubydoc.info/gems/stak)
* [Stak Skeleton](https://github.com/danieljarrett/stak-skeleton)
* [Example App](https://github.com/danieljarrett/stak-application)

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request