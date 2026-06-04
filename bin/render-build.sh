#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# CRITICAL: This checks standard migrations AND builds the missing Solid Cache tables
bundle exec rails db:prepare