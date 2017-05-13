" Commands
com! MatlabRun              cal matlab#run()
com! MatlabBreakpoint       cal matlab#single_breakpoint()
com! MatlabStartServer      cal matlab#start_server()
com! MatlabClearBreakpoint  cal matlab#clear_breakpoint(0)
com! MatlabClearBreakpoints cal matlab#clear_breakpoint(1)

" Key mappings
map <Leader>s :MatlabBreakpoint<CR>
map <Leader>c :MatlabClearBreakpoint<CR>
map <Leader>C :MatlabClearBreakpoints<CR>
map <Leader>r :MatlabRun<CR>

" Autoload matlab when opening a .m-file
autocmd FileType matlab :MatlabStartServer
