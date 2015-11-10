#!/home/allhailskippy/.rvm/rubies/ruby-2.1.1/bin/ruby
 
ENV['RAILS_ENV'] ||= 'production'
ENV['HOME'] ||= '/home/allhailskippy'
ENV['GEM_HOME'] = File.expand_path('~/.rvm/gems/ruby-2.1.1')
ENV['GEM_PATH'] = File.expand_path('~/.rvm/gems/ruby-2.1.1') + ":" +
    File.expand_path('~/.rvm/gems/ruby-2.1.1@global')
 
require 'fcgi' 
require File.join(File.dirname(__FILE__), '../config/environment')
 
class Rack::PathInfoRewriter
 def initialize(app)
   @app = app
 end
 
 def call(env)
   env.delete('SCRIPT_NAME')
   parts = env['REQUEST_URI'].split('?')
   env['PATH_INFO'] = parts[0]
   env['QUERY_STRING'] = parts[1].to_s
   @app.call(env)
 end
end
 
Rack::Handler::FastCGI.run  Rack::PathInfoRewriter.new(Youtubetonight::Application)
