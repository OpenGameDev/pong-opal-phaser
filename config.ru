require 'bundler'
Bundler.require

opal = Opal::Server.new { |s|
  s.append_path 'lib'
  s.append_path 'assets'

  s.main = 'game'
}

map '/assets' do
  # opal.sprockets.js_compressor = Closure::Compiler.new(:warning_level => 'VERBOSE')
  run opal.sprockets
end

get '/' do
  send_file 'index.html'
end

run Sinatra::Application
