# Pawn-Vim

Vim support for the [Pawn](http://www.compuphase.com/pawn/pawn.htm) programming language.

# Installation

Clone into `~/.vim/bundle`.

# Compiling

To invoke `pawncc` into a quickfix window, add this to your .vimrc:
```
function! MakePawn()
  silent make | copen
  redraw!
endfunction
```

Then, whenever you're editing a pawn file, select the compiler:
```
:compiler pawn
```

And now, run it via 
```
:exec MakePawn()<CR>
```

Optionally, bind it to a keyboard shortcut, like leader-pc (Pawn compile):
```
map <Leader>pc :exec MakePawn()<CR>
```
