#!/bin/bash
function e {
    echo ''
    echo '----------------------------------------'
    echo $1
    echo '----------------------------------------'
}

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

e "Normal spec"
rspec spec/active_record/blueprints_spec.rb
rspec spec/unit/*_spec.rb

e "Without transactions"
NO_TRANSACTIONS=true rspec spec/active_record/blueprints_spec.rb

e "With no db"
rspec spec/no_db/blueprints_spec.rb

e "With Test::Unit"
rake rspec_to_test
ruby test/blueprints_test.rb

e "With Cucumber"
cucumber features/blueprints.feature

e "With Rails 2 and RSpec 1.3.0"
RAILS=2.3.0 spec "_1.3.0_" spec/active_record/blueprints_spec.rb

e "With ruby 1.9.2"
rvm 1.9.2
rspec spec/active_record/blueprints_spec.rb
rspec spec/unit/*_spec.rb

e "With ruby 1.9.1"
rvm 1.9.1
RAILS=2.3.0 spec spec/active_record/blueprints_spec.rb

e "With ruby 1.8.6"
rvm 1.8.6
RAILS=2.3.0 spec spec/active_record/blueprints_spec.rb

rvm system
