; extends

;; ; bullet points
([(list_marker_minus) (list_marker_star)] @punctuation.special (#offset! @punctuation.special 0 0 0 -1) (#set! conceal "•"))

; Checkbox list items
((task_list_marker_unchecked) @punctuation.special (#offset! @punctuation.special 0 -2 0 0) (#set! conceal ""))
((task_list_marker_checked) @comment (#offset! @comment 0 -2 0 0) (#set! conceal ""))
(list_item (task_list_marker_checked)) @comment

; Use box drawing characters for tables
(pipe_table_header ("|") @punctuation.special @conceal (#set! conceal "┃"))
(pipe_table_delimiter_row ("|") @punctuation.special @conceal (#set! conceal "┃"))
(pipe_table_delimiter_cell ("-") @punctuation.special @conceal (#set! conceal "━"))
(pipe_table_row ("|") @punctuation.special @conceal (#set! conceal "┃"))

; Block quotes
((block_quote_marker) @punctuation.special (#offset! @punctuation.special 0 0 0 -1) (#set! conceal "▐"))
((block_quote
  (paragraph (inline
    (block_continuation) @punctuation.special (#offset! @punctuation.special 0 0 0 -1) (#set! conceal "▐")
  ))
))
(block_quote
  (paragraph) @text.literal)

; Needs https://github.com/neovim/neovim/issues/11711
; (fenced_code_block) @codeblock
; (indented_code_block) @codeblock

(list
 (list_item
  (list_marker_minus) @conceal (#set! conceal "")
  (task_list_marker_checked)
  ))

(list
 (list_item
  (list_marker_minus) @conceal (#set! conceal "")
  (task_list_marker_unchecked)
  ))

([(task_list_marker_checked)] @conceal (#set! conceal "")) ;; ✅
([(task_list_marker_unchecked)] @conceal (#set! conceal " ")) ;; 🔲
