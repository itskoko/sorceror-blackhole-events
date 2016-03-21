source 'https://rubygems.org'

gem 'robust-redis-lock', '~> 1.3.1'
gem 'sequel'
gem 'activesupport', '>= 4'

platform :ruby do
  gem 'promiscuous-poseidon_cluster', '~> 0.4.1'
  # gem 'pg' Uncomment and comment pg in jruby section
end

platform :jruby do
  gem "sorceror_jruby-kafka", "~> 2.2.0"
  gem 'pg', '0.17.1', :platform => :jruby, :git => 'git://github.com/headius/jruby-pg.git', :branch => :master
end

group :development, :test do
  gem 'pry'
  gem 'awesome_print'
end
