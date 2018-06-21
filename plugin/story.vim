if exists("g:loaded_story")
  finish
endif
let g:loaded_story = 1

if !exists("g:story_suffix_regex")
    let g:story_suffix_regex = '\(\W\+\w*\|\w\+\)'
endif

if !exists("g:story_base_first")
    let g:story_base_first = 0
endif

if !exists("g:story_autocomplete_last")
    let g:story_autocomplete_last = 0
endif

command! Story call story#begin()
