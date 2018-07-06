source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '>= 5.0'
gem 'pg'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer', platforms: :ruby

gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Auth
gem 'devise'

# Heroku stuff
gem 'rack-zippy'

#Frontend
gem 'haml-rails'
gem 'react-rails'
gem 'react-flux-rails'
gem 'sprockets-es6'
gem 'material_design_lite-rails'
gem 'recaptcha', require: 'recaptcha/rails'

gem 'codeclimate-test-reporter', group: :test, require: nil

gem 'countries', :require => 'countries/global'
gem 'country_select', require: 'country_select_without_sort_alphabetical'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rubocop', require: false
end

group :development do
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do
  gem 'rails_12factor'
end
