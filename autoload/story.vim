if exists("g:autoloaded_story")
  finish
endif
let g:autoloaded_story = 1

if !exists("g:story_suffix_regex")
    let g:story_suffix_regex = '\(\W\+\w*\|\w\+\)'
endif

if !exists("g:story_base_first")
    let g:story_base_first = 0
endif

if !exists("g:story_autocomplete_last")
    let g:story_autocomplete_last = 0
endif

function! story#begin() abort
    if &ft == 'story'
        return
    endif
    let current_word = expand('<cword>')
    let s:current_column = col('.')
    let current_line = getline('.')
    let s:current_buffer_number = bufnr('%')
    let s:current_column = match(current_line, '\w', s:current_column - 1) + 1
    if s:current_column == 0
        return
    endif
    let s:lines = getbufline(s:current_buffer_number, 1, '$')
    let s:prev_bases = []
    let s:revert_hidden = 0
    if !&l:hidden
        let s:revert_hidden = 1
        setlocal hidden
    endif
    enew
    call s:complete(current_word)
endfunction

function! s:set_buffer_settings()
    setlocal undolevels=-1
    setlocal ft=story
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
endfunction

function! s:complete(base)
    silent %delete _
    let pattern = '\<' . escape(a:base, '\') . g:story_suffix_regex
    let matches = []
    if (g:story_base_first)
        let matches = [a:base]
    endif
    for line in s:lines
        let end_pos = 0
        while 1
            " If performance is an issue, we may prune by removing lines
            " that don't have matches, but then changing the completion
            " halfway will not have the expected results.
            let start_pos = end_pos
            let end_pos = matchend(line, pattern, start_pos)
            if end_pos == -1
                break
            endif
            let potential_match = matchstr(line, pattern, start_pos)
            if !empty(potential_match) && index(matches, potential_match) == -1
                call add(matches, potential_match)
            endif
        endwhile
    endfor

    if !g:story_base_first
        call add(matches, a:base)
    endif
    call s:set_buffer_settings()
    call setline(1, matches)
    setlocal undolevels<
    if (g:story_autocomplete_last && len(matches) == 1) ||
     \ (!empty(s:prev_bases)  && a:base == s:prev_bases[-1])
        call story#end(a:base)
    endif
    call add(s:prev_bases, a:base)
endfunction


function story#continue() abort
    let current_line = getline('.')
    call s:complete(current_line)
endfunction

function story#back() abort
    if (len(s:prev_bases) < 2)
        return
    endif
    call remove(s:prev_bases, -1)
    let last = s:prev_bases[-1]
    call remove(s:prev_bases, -1)
    call s:complete(last)
endfunction

function story#end(...) abort
    if a:0
        let current_line = a:1
    else
        let current_line = getline('.')
    endif
    execute ":buffer " . s:current_buffer_number

    if (s:revert_hidden)
        setlocal nohidden
    endif
    execute 'normal ' . s:current_column . '|ciw' . current_line
endfunction
