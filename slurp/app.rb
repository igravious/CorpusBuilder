require 'rubygems'
require 'bundler/setup'

require 'active_record'
require 'yaml'

module App
	def self.setup_migrations
		ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
	end

	def self.setup_database
		yml = YAML::load(File.open('db/database.yml'))
		ActiveRecord::Base.establish_connection(yml)
		# ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
		ActiveRecord::Base.logger = Logger.new(STDERR)
		#
		ActiveRecord::Base.connection.execute 'SET NAMES UTF8'
	end
end
