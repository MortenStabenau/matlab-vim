" ----------------------------------------------------------------------------
" Public functions
" ----------------------------------------------------------------------------
function! matlab#start_server()
  if !matlab#_tmux_exists()
    return
  endif

  if matlab#_get_server_pane() == -1
    " Create new pane and save its id
    let cmd = 'split-window -dhPp 35 -F "#{pane_index}"'
    let g:matlab_server_pane = substitute(matlab#_tmux(cmd), '[^0-9]', '', 'g')

    " Launch matlab
    let cmd = 'matlab -nodesktop -nosplash -r "cd '.matlab#_get_project_root().';"'
    cal matlab#_run("clear && ".cmd, 0)

    " Zoom current pane
    cal matlab#_tmux('resize-pane -Z')
  endif
endfunction

function! matlab#run(...)
  if !matlab#_tmux_exists()
    return
  endif

  cal matlab#_open_pane()
  if a:0
    cal matlab#_run(a:1)
  else
    cal matlab#_run(matlab#_filename())
  endif
endfunction

function! matlab#single_breakpoint()
  if ! matlab#_tmux_exists()
    return
  endif

  write
  let f = matlab#_filename()
  let cmd = 'dbclear '.f.';dbstop '.f.' at '.line('.')
  cal matlab#_run(cmd)
endfunction

function! matlab#clear_breakpoint(all)
  if ! matlab#_tmux_exists()
    return
  endif

  if a:all
    cal matlab#_run('dbclear all')
  else
    cal matlab#_run('dbclear '.matlab#_filename().';')
  endif
endfunction

function! matlab#doc()
  if ! matlab#_tmux_exists()
    return
  endif

  let r = matlab#_run('help '.expand('<cword>'))
  cal matlab#_open_pane()
  return r
endfunction

" ----------------------------------------------------------------------------
" Internal functions
" ----------------------------------------------------------------------------
function! matlab#_run(command, ...)
  if &syntax ==? 'matlab'
    let target = matlab#_get_server_pane()

    if target != -1
      " Send control-c to abort any running command except when it is disabled
      " by an additional argument
      if ! a:0 || (a:0 && a:1)
        cal matlab#_tmux('send-keys -t .'.target.' C-c')
      endif

      let cmd = escape(a:command, '"')
      let r =  matlab#_tmux('send-keys -t .'.target.' "'.cmd.'"')
      cal matlab#_tmux('send-keys -t .'.target.' Enter')
      return r
    else
      echom 'Matlab pane could not be found'
    endif

  else
    echom 'Not a matlab script'
  endif
endfunction

function! matlab#_get_project_root()
  let dir = projectroot#guess()
  let mldir = glob(dir.'/matlab*')

  if !empty(mldir)
    let dir = split(mldir, '\n')[0]
  endif

  return dir
endfunction

function! matlab#_open_pane()
  return matlab#_tmux('select-pane -t .'.matlab#_get_server_pane())
endfunction

function! matlab#_tmux_exists()
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
  if exists('g:matlab_server_pane')
    return g:matlab_server_pane
  endif

  let cmd = 'list-panes -F "#{pane_index}:#{pane_current_command}"'
  let views = split(matlab#_tmux(cmd), '\n')

  for view in views
    if match(view, 'MATLAB') != -1
      let g:matlab_server_pane = split(view, ':')[0]
      return matlab_server_pane
    endif
  endfor

  return -1
endfunction
