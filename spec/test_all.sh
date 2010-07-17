#!/bin/bash
function e {
    echo ''
    echo '----------------------------------------'
    echo $1
    echo '----------------------------------------'
}

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

e "Normal spec"
spec spec/active_record/blueprints_spec.rb

e "Without transactions"
NO_TRANSACTIONS=true spec spec/active_record/blueprints_spec.rb

e "With no db"
spec spec/no_db/blueprints_spec.rb

e "With Test::Unit"
rake rspec_to_test
ruby test/blueprints_test.rb

e "With Cucumber"
cucumber features/blueprints.feature

e "With Rails 3"
rvm 1.8.7
RAILS=3 rspec spec/active_record/blueprints_spec.rb

e "With ruby 1.9.1"
rvm 1.9.1
spec spec/active_record/blueprints_spec.rb

e "With ruby 1.8.6"
rvm 1.8.6
spec spec/active_record/blueprints_spec.rb

rvm system
