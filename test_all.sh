#!/bin/bash
function e {
    echo ''
    echo '----------------------------------------'
    echo $1
    echo '----------------------------------------'
}

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

e "Normal spec"
rspec -c spec/blueprints_spec.rb
rspec -c spec/unit/*_spec.rb

e "With no db"
ORM=none rspec -c spec/blueprints_spec.rb

e "With mongoid"
ORM=mongoid rspec -c spec/blueprints_spec.rb

e "With mongo_mapper"
ORM=mongo_mapper rspec -c spec/blueprints_spec.rb

e "With Test::Unit"
rake rspec_to_test
ruby test/blueprints_test.rb

e "With Cucumber"
cucumber features/blueprints.feature -f progress

e "With ruby 1.9.2"
rvm 1.9.2
rspec -c spec/blueprints_spec.rb
rspec -c spec/unit/*_spec.rb

e "With rubinius"
rvm rbx
rspec -c spec/blueprints_spec.rb
rspec -c spec/unit/*_spec.rb

rvm system
