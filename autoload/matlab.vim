function! matlab#start_server()
  if !matlab#_tmux_exists()
    return
  endif

  if matlab#_get_server_pane() == -1
    cal matlab#_tmux('split-window -dhp 35')

    " Get new pane number
    let panes = split(matlab#_tmux('list-panes -F "#{pane_index}"'), '\n')
    let cmd   = 'clear && matlab -nodesktop -nosplash'
    cal matlab#_tmux('send-keys -t '.panes[-1].' "'.cmd.'" Enter')

    " Zoom current pane
    cal matlab#_tmux('resize-pane -Z')
  endif
endfunction

function! matlab#run()
  call matlab#_run(matlab#_filename())
endfunction

function! matlab#single_breakpoint()
  write
  let f = matlab#_filename()
  let cmd = 'dbclear '.f.';dbstop '.f.' at '.line('.')
  call matlab#_run(cmd)
endfunction

function! matlab#_run(command)
  if &syntax ==? 'matlab'
    let target = matlab#_get_server_pane()

    if target != -1
      cal matlab#_tmux('send-keys -t'.target.' C-c')
      return matlab#_tmux('send-keys -t '.target.' "'.a:command.'" Enter')
    else
      echom 'Matlab pane could not be found'
    endif

  else
    echom 'Not a matlab script'
  endif
endfunction

function matlab#_tmux_exists()
  if empty($TMUX)
    echom "matlab.vim can not run without tmux"
    return 0
  endif

  return 1
endfunction

function! matlab#_tmux(command)
  return system('tmux '.a:command)
endfunction

function! matlab#_filename()
  return substitute(expand('%:t'), '\.m', '', 'g')
endfunction

function! matlab#_get_server_pane()
  let cmd = 'list-panes -F "#{pane_index}:#{pane_current_command}"'
  let views = split(matlab#_tmux(cmd), '\n')

  for view in views
    if match(view, 'MATLAB') != -1
      return split(view, ':')[0]
    endif
  endfor

  return -1
endfunction
