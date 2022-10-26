#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
yarn install
bundle exec rake assets:clobber RAILS_ENV=production
bundle exec rake assets:precompile RAILS_ENV=production
bundle exec rake assets:clean
bundle exec rake db:migrate
