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

  s.add_dependency 'solidus_core', '~> 1.2'
  s.add_dependency 'http', '~> 2.0'
  s.add_dependency 'ruby-progressbar', '~> 1.0' # already a solidus dependency

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop', '0.37.2'
  s.add_development_dependency 'rubocop-rspec', '1.4.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'vcr', '~> 3.0'
  s.add_development_dependency 'webmock', '~> 2.1'
end
