" Commands
com! MatlabRun              cal matlab#run()
com! MatlabBreakpoint       cal matlab#single_breakpoint()
com! MatlabStartServer      cal matlab#start_server()
com! MatlabClearBreakpoint  cal matlab#clear_breakpoint(0)
com! MatlabClearBreakpoints cal matlab#clear_breakpoint(1)
com! MatlabDocumentation    cal matlab#doc()
com! MatlabDoc              cal matlab#doc()

" Key mappings
map <Leader>s :MatlabBreakpoint<CR>
map <Leader>c :MatlabClearBreakpoint<CR>
map <Leader>C :MatlabClearBreakpoints<CR>
map <Leader>d :MatlabDoc<CR>
map <Leader>r :MatlabRun<CR>

" Autoload matlab when opening a .m-file
autocmd FileType matlab :MatlabStartServer
