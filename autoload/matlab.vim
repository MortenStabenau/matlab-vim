" ----------------------------------------------------------------------------
" Public functions
" ----------------------------------------------------------------------------

" Open a matlab instance in a new tmux split
function! matlab#start_server(...)
  " First argument is true if this is called by the autostart function
  if !matlab#_tmux_exists()
    return
  endif

  " Check if autostart is enabled
  if a:0 && a:1 && ! g:matlab_auto_start
    return
  end

  if matlab#_get_server_pane() == -1
    " Create new pane, start matlab in it and save its id
    " Yeah, this is a reeeeally long command
    let change_dir = 'cd '.matlab#_get_project_root().';'
    let mlcmd = 'clear && '.g:matlab_executable.' -nodesktop -nosplash'.
          \ ' -r \"'.change_dir.'\"'
    let cmd = 'split-window -dhPF "#{pane_index}" "' . mlcmd . '"'
    let g:matlab_server_pane = substitute(matlab#_tmux(cmd), '[^0-9]', '', 'g')
    echom 'Matlab server started.'

    " Set pane size
    cal matlab#_tmux('resize-pane -t ' . g:matlab_server_pane . ' -x ' . g:matlab_panel_size)

    " Zoom current pane
    cal matlab#_tmux('resize-pane -Z')
  endif
endfunction

function! matlab#stop_server()
  if !matlab#_tmux_exists()
    return
  endif

  if matlab#_get_server_pane() != -1
    cal matlab#_run('quit')
    unlet g:matlab_server_pane
  endif
endfunction

" Run an arbitrary command. If the command is left empty, the current file is
" executed
function! matlab#run(...)
  if !matlab#_tmux_exists()
    return
  endif

  cal matlab#_open_pane()
  if a:0
    cal matlab#_run(a:1)
  else
    " Make sure that this is actually a matlab script
    if ! matlab#_is_ml_script()
        return
    end
    write
    cal matlab#_run(matlab#_filename())
  endif
endfunction

" Remove breakpoints from current file and create a new one in the current line
function! matlab#single_breakpoint()
  if ! matlab#_tmux_exists()
    return
  endif

  if ! matlab#_is_ml_script()
      return
  end

  write
  let f = matlab#_filename()
  let cmd = 'dbclear '.f.';dbstop '.f.' at '.line('.')
  cal matlab#_run(cmd)
endfunction

" Clear breakpoints in current file. If all is true, breakpoints outside the
" current file will be cleared aswell.
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

" Show help for a matlab function under the cursor
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
function! matlab#_is_ml_script()
  if (&syntax ==? 'matlab' || &syntax ==? 'octave')
      return 1
  else
    echom 'Not a matlab script.'
    return 0
  endif
endfunction

function! matlab#_run(command, ...)
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
    echom 'Matlab pane could not be found. Start Matlab? [Y/n]'
    let c = getchar()
    if nr2char(c) == 'y'
        cal matlab#start_server()
        cal matlab#_tmux('send-keys Enter') " To dismiss the Press ENTER to continue message
    endif
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
    echom "matlab.vim can not run without tmux."
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

  let cmd = 'list-panes -F "#{pane_index}:#{pane_start_command}"'
  let views = split(matlab#_tmux(cmd), '\n')

  for view in views
    " Check if the start command contains matlab (case-insensitive)
    if match(view, '\cmatlab') != -1
      let g:matlab_server_pane = split(view, ':')[0]
      return g:matlab_server_pane
    endif
  endfor

  return -1
endfunction
