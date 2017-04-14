function! matlab#run()
  if &syntax ==? 'matlab'
    call matlab#_run(matlab#_filename())
  else
    echom "Not a matlab script"
  endif
endfunction

function! matlab#_run(command)
  let target = matlab#_get_server_pane()
  return matlab#_tmux("send-keys -t ".target." ".a:command." Enter")
endfunction

function! matlab#_tmux(command)
  return system('tmux '.a:command)
endfunction

function! matlab#_filename()
  return substitute(expand('%:t'), '\.m', '', 'g')
endfunction

function! matlab#_get_server_pane()
  let cmd = 'list-panes -F "#{pane_index}:#{pane_current_command}"'
  let views = split(matlab#_tmux(cmd), "\n")

  for view in views
    if match(view, "MATLAB") != -1
      return split(view, ":")[0]
    endif
  endfor

  return -1
endfunction
