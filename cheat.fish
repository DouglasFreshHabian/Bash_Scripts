#!/bin/bash

# Shell autocompletion script to be used with fish
# Move this script to the correct directory for autocompletion
complete -c cheat -f -a "(cheat -l | tail -n +2 | cut -d ' ' -f 1)"
complete -c cheat -l init -d "Write a default config file to stdout"
complete -c cheat -s c -l colorize -d "Colorize output"
complete -c cheat -s d -l directories -d "List cheatsheet directories"
complete -c cheat -s e -l edit -x -a "(cheat -l | tail -n +2 | cut -d ' ' -f 1)" -d "Edit cheatsheet"
complete -c cheat -s l -l list -d "List cheatsheets"
complete -c cheat -s p -l path -x -a "(cheat -d | cut -d ':' -f 1)" -d "Return only sheets found on given path"
complete -c cheat -s r -l regex -d "Treat search phrase as a regex"
complete -c cheat -s s -l search -x -d "Search cheatsheets for given phrase"
complete -c cheat -s t -l tag -x -a "(cheat -T)" -d "Return only sheets matching the given tag"
complete -c cheat -s T -l tags -d "List all tags in use"
complete -c cheat -s v -l version -d "Print the version number"
complete -c cheat -l rm -x -a "(cheat -l | tail -n +2 | cut -d ' ' -f 1)" -d "Remove (delete) cheatsheet"
