" Vim syntax file
" Language:	Bildad column

setl rightleft
setl rightleftcmd
setl keymap=hebrew
setl tw=40
setl formatoptions=am
setl noai

syn match question "שאלה:\n\n\_.\{-}\n\n"
syn match answer "תשובה:\n\n\_.\{-}\n\n\n"
syn match short "קצר:\n\n\_.\{-}\n\n"

hi question guifg=red
hi answer guifg=green
hi short guifg=blue

let b:current_syntax = "bildad"

" vim: ts=8 sw=2
