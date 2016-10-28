# encoding: UTF-8
$:.push File.expand_path('../lib', __FILE__)
require 'solidus_mailchimp_sync/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_mailchimp_sync'
  s.version     = SolidusMailchimpSync::VERSION
  s.summary     = 'Solidus -> Mailchimp Ecommerce synchronization'
  s.license     = 'BSD-3-Clause'

  s.author    = 'Jonathan Rochkind, Friends of the Web'
  s.email     = 'shout@friendsoftheweb.com'
  s.homepage  = 'http://github.com/friendsoftheweb/solidus_mailchimp_sync'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'solidus_core', '~> 2.0'
  s.add_dependency 'http', '~> 2.0'
  s.add_dependency 'ruby-progressbar', '~> 1.0' # already a solidus dependency

  s.add_development_dependency 'capybara', '~> 2.10'
  s.add_development_dependency 'poltergeist', '~> 1.11'
  s.add_development_dependency 'coffee-rails', '~> 4.2'
  s.add_development_dependency 'sass-rails', '~> 5.0'
  s.add_development_dependency 'database_cleaner', '~> 1.5'
  s.add_development_dependency 'factory_girl', '~> 4.7'
  s.add_development_dependency 'rspec-rails', '~> 3.5'
  s.add_development_dependency 'rubocop', '~> 0.44'
  s.add_development_dependency 'rubocop-rspec', '~> 1.8'
  s.add_development_dependency 'simplecov', '~> 0.12'
  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'vcr', '~> 3.0'
  s.add_development_dependency 'webmock', '~> 2.1'
end
