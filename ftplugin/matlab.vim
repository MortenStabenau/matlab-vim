" Key mappings
if g:matlab_default_mappings
  map <buffer> <Leader>s :MatlabBreakpoint<CR>
  map <buffer> <Leader>c :MatlabClearBreakpoint<CR>
  map <buffer> <Leader>C :MatlabClearBreakpoints<CR>
  map <buffer> <Leader>d :MatlabDoc<CR>
  map <buffer> <Leader>r :MatlabRun<CR>
endif
