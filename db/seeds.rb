# coding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
require 'csv'
require 'rake'

# NJ-05/01/2011 => If you're looking for a place for Cucumber seed data, try the seed_steps.rb file.  This is to be reserved for loads of static data.

TablesToClear = [] unless defined?(TablesToClear)

for table in TablesToClear
  table.delete_all
end

puts "Invoking seed_fu"
#SeedFu.quiet=true
SeedFu.seed#("/db/fixtures/generated")


puts "Initializing Member counters"
MemberCountCalculator.init_all_counts!
