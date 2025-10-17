((diff) @injection.content
 (#set! injection.combined)
 (#set! injection.language "diff"))

((rebase_command) @injection.content
 (#set! injection.combined)
 (#set! injection.language "git_rebase"))

; Text parser should tokenize individual words
((message_line) @injection.content
 (#set! injection.language "markdown"))
