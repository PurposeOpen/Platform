# require 'benchmark'
# 
# def require(file)
#   result = nil
#   puts Benchmark.measure("") {
#     result = super
#   }.format("%t require #{file}")
#   result
# end



require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
