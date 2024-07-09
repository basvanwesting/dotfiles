" Preloaded macros
" change hash to ruby 1.9 notation
let @h = ':%s/:\([a-zA-Z0-9_?!]*\)\(\s*\)=>/\1:/g'
" change to underscore notation
" let @u = 'viw:s#\C\(\<\u[a-z0-9]\+\|[a-z0-9]\+\)\(\u\)#\l\1_\l\2#g,/'
" change to camelcase notation
" let @c = 'viw:s#\(\%(\<\l\+\)\%(_\)\@=\)\|_\(\l\)#\u\1\2#g,/'
" strip parameter whitespace
" let @p = ':%s/\v\(\s+(\S)/(\1/g:%s/\v(\S)\s+\)/\1)/g'
" change rspec should to expect syntax
" let @r = '/\.should[ _]+cfd).to0wiexpect('
" change rspec == to eq
" let @t = '/\.to\s+\=\=c2f=.to eq'
" symbolize strings
let @y = ':%s/\v"([[:alnum:]_]{1,})"/:\1/g'
