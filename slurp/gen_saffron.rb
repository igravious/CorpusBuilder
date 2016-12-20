#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

# require 'pry'
 
require_relative 'app'
App.setup_database()
 
require_relative 'models'

# https://stackoverflow.com/questions/2694106/case-insensitive-duplicates-sql

# reduces from 60049 to 37396

sql = "SELECT SUM(matches) AS totes, term_string, pattern FROM `PaperTerm` GROUP BY term_string ORDER BY totes DESC"
records_array = ActiveRecord::Base.connection.execute(sql)

records_array.each_with_index do |r, i|
	puts "#{r[0]}, #{r[1]}, #{r[2]}"
end
