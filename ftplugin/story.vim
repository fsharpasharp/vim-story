execute 'nnoremap <buffer><silent> q :bdelete<CR>'
execute 'nnoremap <buffer><silent> - :call story#back()<CR>'
execute 'nnoremap <buffer><silent> <BS> :call story#end()<CR>'
execute 'nnoremap <buffer><silent> <CR> :call story#continue()<CR>'
