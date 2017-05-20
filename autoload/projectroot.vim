if &cp || exists('autoloaded_projectroot')
  finish
endif
let autoloaded_projectroot = 1

if !exists('g:rootmarkers')
  let g:rootmarkers = ['.projectroot', '.git', '.hg', '.svn', '.bzr', '_darcs', 'build.xml']
endif

function! projectroot#get(...)
  let fullfile = s:getfullname(a:0 ? a:1 : '')
  if exists('b:projectroot')
    if stridx(fullfile, fnamemodify(b:projectroot, ':p'))==0
      return b:projectroot
    endif
  endif
  if fullfile =~ '^fugitive:/'
    if exists('b:git_dir')
      return fnamemodify(b:git_dir, ':h')
    endif
    return '' " skip any fugitive buffers early
  endif
  for marker in g:rootmarkers
    let pivot=fullfile
    while 1
      let prev=pivot
      let pivot=fnamemodify(pivot, ':h')
      let fn = pivot.(pivot == '/' ? '' : '/').marker
      if filereadable(fn) || isdirectory(fn)
        return pivot
      endif
      if pivot==prev
        break
      endif
    endwhile
  endfor
  return ''
endfunction

function! projectroot#guess(...)
  let projroot = projectroot#get(a:0 ? a:1 : '')
  if len(projroot)
    return projroot
  endif
  " Not found: return parent directory of current file / file itself.
  let fullfile = s:getfullname(a:0 ? a:1 : '')
  return !isdirectory(fullfile) ? fnamemodify(fullfile, ':h') : fullfile
endfunction

function! s:getfullname(f)
  let f = a:f
  let f = f=~"'." ? s:getmarkfile(f[1]) : f
  let f = len(f) ? f : expand('%')
  return fnamemodify(f, ':p')
endfunction

function! s:getmarkfile(mark)
  try
    redir => m
    sil exe ':marks' a:mark
    redir END
    let f = split(split(m,'\n')[-1])[-1]
    return filereadable(f) ? f : ''
  catch
    return ''
  endtry
endfunction
