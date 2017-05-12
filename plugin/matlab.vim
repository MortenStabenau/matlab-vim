" Commands
com! MatlabRun              cal matlab#run()
com! MatlabBreakpoint       cal matlab#single_breakpoint()
com! MatlabStartServer      cal matlab#start_server()

" Key mappings
map <Leader>s :MatlabBreakpoint<CR>
map <Leader>r :MatlabRun<CR>

" Autoload matlab when opening a .m-file
autocmd FileType matlab :MatlabStartServer
