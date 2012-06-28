source :rubygems

gem 'sinatra', '~> 1.3.2'
gem 'addressable', '~> 2.2.8'
gem 'activesupport', '~> 3.2.6'

group :production do
  gem 'unicorn', '4.3.1'
end

group :test do
  gem 'rake'
  gem 'minitest', '~> 3.1.0'
  gem 'minitest-reporters', '~> 0.7.1'
  gem 'rack-test', '~> 0.6.1'
  gem 'mocha', '~> 0.11.4', require: false

  # Guard
  gem 'guard', '~> 1.2.1'
  gem 'guard-minitest', '~> 0.5.0'
  gem 'rb-fsevent'
end
