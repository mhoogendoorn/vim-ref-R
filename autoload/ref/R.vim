" vim-ref source for R help

let s:rscript_cmd = 'Rscript'

" source definition
let s:source = {'name': 'R'}

" required, return the reference
function! s:source.get_body(query)
    let res = ref#system([s:rscript_cmd, '--vanilla', "-e", "options(pager='cat'); ?`".a:query."`"])
    if res.result != 0
        throw "Unable to read documentation for '".a:query."'"
    endif
    if match(res.stdout, '^No documentation for') == 0
        throw "No documentation for '".a:query."'"
    endif
    return res.stdout
endfun

" optional, return true if source available
function! s:source.available()
    return executable(s:rscript_cmd)
endfunction

" optional, called when reference page is opened
function! s:source.opened(query)
    setlocal iskeyword=@,48-57,_,.
    call s:FixRdoc()
    call s:syntax()
    setl nolist
    " avoid folding of examples
    setl foldlevel=99
endfunction

" optional pick keyword from current cursos pos (default is expand('<cword>'))
" function! s:source.get_keyword()
" endfunction

" optional, return complete list for command line
" function! s:source.complete(query)
" endfunction

" optional normalize query (used as buffer name, get_body, opened)
" function! s:source.normalize(query)
" endfunction

" optional, called when moving to other source page
" function! s:source.leave()
" endfunction

" defined by core, shortcut to ref#cache()
" function! s:source.cache(name, gather, update)
" endfunction

" this is called automatically, result is registered as source
function! ref#R#define()
    return copy(s:source)
endfunction

" filetype 'r' uses this source
call ref#register_detection('r', 'R')

" utility functions
" adapted from similar function in ftplugin/rdoc.vim in Vim-R-plugin.
function! s:FixRdoc()
    let lnr = line("$")
    for i in range(1, lnr)
        call setline(i, substitute(getline(i), "_\010", "", "g"))
    endfor
    let has_ex = search("^Examples:$")
    " avoid adding double '###' when jumping back and forth in ref-viewer.
    if has_ex && match(getline(line("$")), '^###$') == -1
        let lnr = line("$") + 1
        call setline(lnr, '###')
    endif
    keepjumps normal! gg
endfunction

" adapted from syntax/rdoc.vim in Vim-R-plugin.
function! s:syntax()
    syn match  rdocTitle	      "^[A-Z].*:"
    syn match  rdocTitle "^\S.*R Documentation$"
    syn region rdocStringS  start="â" end="â"
    syn region rdocStringS  start="" end=""
    syn region rdocStringD  start='"' skip='\\"' end='"'
    syn match rdocURL `\v<(((https?|ftp|gopher)://|(mailto|file|news):)[^'	<>"]+|(www|web|w3)[a-z0-9_-]*\.[a-z0-9._-]+\.[^'  <>"]+)[a-zA-Z0-9/]`
    syn keyword rdocNote		note Note NOTE note: Note: NOTE: Notes Notes:
    syn match rdocArg  "^\s*\([a-z]\|[A-Z]\|[0-9]\|\.\|_\)*: "

    syn include @rdocR syntax/r.vim
    syn region rdocExample matchgroup=rdocExTitle start="^Examples:$" matchgroup=rdocExEnd end='^###$' contains=@rdocR keepend

    " When using vim as R pager to see the output of help.search():
    syn region rdocPackage start="^[A-Za-z]\S*::" end="[\s\r]" contains=rdocPackName,rdocFuncName transparent
    syn match rdocPackName "^[A-Za-z][A-Za-z0-9\.]*" contained
    syn match rdocFuncName "::[A-Za-z0-9\.\-_]*" contained

    " Define the default highlighting.
    hi def link rdocTitle	    Title
    hi def link rdocExTitle   Title
    hi def link rdocExEnd   Comment
    hi def link rdocStringS     Function
    hi def link rdocStringD     String
    hi def link rdocURL    HtmlLink
    hi def link rdocArg         Special
    hi def link rdocNote  Todo

    hi def link rdocPackName Title
    hi def link rdocFuncName Function
endfunction

