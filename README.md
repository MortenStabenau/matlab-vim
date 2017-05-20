# matlab.vim - a vim plugin for using MATLAB and tmux

This plugin provides some simple integration between vim, MATLAB and tmux. On
opening a MATLAB file (for example a .m-file) the plugin launches a MATLAB
console in a new hidden tmux split at the right of the current split. The split
is hidden by zooming the current pane and can be unhidden by using
`prefix+rightarrow`, for example.

The plugin now provides multiple functions and mappings
 which make it easier to interact with MATLAB. These include
running scripts, adding breakpoints and opening documentation.

matlab.vim also includes syntax highlighting, which was copied from
[MatlabFilesEdition](http://www.vim.org/scripts/script.php?script_id=2407) by
Fabrice Guy.

## Installation
Use your favourite vim plugin manager. I recommend using
[vim-plug](https://github.com/junegunn/vim-plug). To install this plugin add
this to your `.vimrc`:

```
Plug 'MortenStabenau/matlab-vim'
```

And then run `:PlugInstall`.

## Documentation
For a full documentation detailing the commands and mappings, please read the
[doc](https://github.com/MortenStabenau/matlab-vim/blob/master/doc/matlab.txt)
file or run `help matlab`. The latter also gives you pretty syntax
highlighting.

## TODO
- Add new MATLAB functions to highlighting: the old MatlabFilesEdition code was
  written in 2009 or so. Since then, a lot of new MATLAB functions have been
  added which are currently not recognized by the syntax highlighting.
- Add a few configuration options
- Display breakpoints (?)
- Add `:MatlabStopServer` command (?)

## Thanks
- Fabrice Guy:
For his work on
[MatlabFilesEdition](http://www.vim.org/scripts/script.php?script_id=2407). I
used his code for the syntax highlighting and the indentation.
- Daan Bakker:
or his handy [projectroot](https://github.com/dbakker/vim-projectroot)
functions
