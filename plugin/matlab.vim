" Options
let g:matlab_default_mappings = get(g:, 'matlab_default_mappings', 1)
let g:matlab_executable       = get(g:, 'matlab_executable', 'matlab')
let g:matlab_panel_size       = get(g:, 'matlab_panel_size', 120)
let g:matlab_auto_start       = get(g:, 'matlab_auto_start', 1)

" Commands
com! -nargs=? MatlabRun     cal matlab#run(<args>)
com! MatlabBreakpoint       cal matlab#single_breakpoint()
com! MatlabStartServer      cal matlab#start_server()
com! MatlabAutoStartServer  cal matlab#start_server(1)
com! MatlabStopServer       cal matlab#stop_server()
com! MatlabClearBreakpoint  cal matlab#clear_breakpoint(0)
com! MatlabClearBreakpoints cal matlab#clear_breakpoint(1)
com! MatlabDocumentation    cal matlab#doc()
com! MatlabDoc              cal matlab#doc()

" Autoload matlab when opening a .m-file
augroup matlab-vim
    autocmd FileType matlab :MatlabAutoStartServer
    autocmd VimLeave * :MatlabStopServer
augroup END
