#!/bin/bash
function e {
    echo ''
    echo '----------------------------------------'
    echo $1
    echo '----------------------------------------'
}

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

e "Ruby 1.8.7"
rvm 1.8.7 rake

e "Ruby 1.9.2"
rvm 1.9.2 rake

e "Rubinius"
rvm rbx rake
