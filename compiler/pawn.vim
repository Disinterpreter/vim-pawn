" Vim compiler file
" Compiler:     Pawn
" Maintainer:   Michael Nelson <michael@nelsonware.com>
" Last Change:  2014 March 15

if exists("current_compiler")
  finish
endif
let current_compiler = "pawn"

if exists(":CompilerSet") != 2
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo-=C

CompilerSet makeprg=pawncc\ %
CompilerSet errorformat=%f\(%l\)\ :\ fatal\ %t%*[^0-9]%n:\ %m,%f\(%l\)\ :\ %t%*[^0-9]%n:\ %m

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2:
