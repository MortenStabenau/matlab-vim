" Commands
com! MatlabRun cal matlab#run()
com! MatlabSetSingleBreakpoint cal matlab#single_breakpoint()
com! MatlabStartServer cal matlab#start_server()

" Key mappings
map <Leader>s :MatlabSetSingleBreakpoint<CR>

" Autoload matlab when opening a .m-file
autocmd FileType matlab :MatlabStartServer
