; extends

; don't spell-check html color specs
(string
      (string_fragment) @name @string (#match? @string "^#[0-9a-f]{6,8}$")) @nospell
