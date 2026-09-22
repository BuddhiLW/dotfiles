" syntax/cartoflow.vim -- the carto-flow://timeline buffer
"
" Timeline line layout (hive-carto-flow.render.text/frame-line, prefixed with
" a two-character cursor column):
"   > #12   OK succeeded   write-form   src/a.clj (+1)   -- summary

if exists('b:current_syntax')
  finish
endif

syntax match cartoFlowTitle   /\%1l.*/
syntax match cartoFlowCount   /\%2l.*/ contains=cartoFlowLive,cartoFlowDead
syntax match cartoFlowLive    /\[connected [^]]*\]/ contained
syntax match cartoFlowDead    /\[disconnected\]/ contained
syntax match cartoFlowRule    /^-\{10,}$/
syntax match cartoFlowWaiting /^Waiting for Carto operations\.\.\.$/

syntax match cartoFlowCursor  /^> /
syntax match cartoFlowIndex   /^[> ] \zs#\d\+/
syntax match cartoFlowSummary /  -- .*$/

let s:prefix = '/^[> ] #\d\+\s\+\S\+\s\+\zs'
execute 'syntax match cartoFlowIntent '     . s:prefix . 'intent\>/'
execute 'syntax match cartoFlowApply '      . s:prefix . 'apply\>/'
execute 'syntax match cartoFlowImpact '     . s:prefix . 'impact\>/'
execute 'syntax match cartoFlowVerify '     . s:prefix . 'verify\>/'
execute 'syntax match cartoFlowSucceeded '  . s:prefix . 'succeeded\>/'
execute 'syntax match cartoFlowFailed '     . s:prefix . 'failed\>/'
execute 'syntax match cartoFlowRolledBack ' . s:prefix . 'rolled-back/'
unlet s:prefix

highlight default link cartoFlowTitle      Title
highlight default link cartoFlowCount      Comment
highlight default link cartoFlowLive       String
highlight default link cartoFlowDead       WarningMsg
highlight default link cartoFlowRule       Comment
highlight default link cartoFlowWaiting    Comment
highlight default link cartoFlowCursor     Todo
highlight default link cartoFlowIndex      Number
highlight default link cartoFlowSummary    Comment
highlight default link cartoFlowIntent     Comment
highlight default link cartoFlowApply      Identifier
highlight default link cartoFlowImpact     Type
highlight default link cartoFlowVerify     PreProc
highlight default link cartoFlowSucceeded  DiffAdd
highlight default link cartoFlowFailed     ErrorMsg
highlight default link cartoFlowRolledBack WarningMsg

let b:current_syntax = 'cartoflow'
