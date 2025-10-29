; extends
(object
  (pair
    key: (_) @property.lhs
    value: (_) @property.inner @property.rhs) @property.outer)


(jsx_element
  open_tag: (_)
  (_)+ @tag.inner ; Capture everything between open and close tag
                  ; This works because 'mini.surround' computes matching
                  ; region based on all captures: from the start of the leftmost
                  ; one to the end of the rightmost one (i.e. union of regions).
  close_tag: (_)) @tag.outer

(jsx_element
  open_tag: (jsx_opening_element
    name: (identifier) @tag_name.outer
    (_)* @tag_name.inner
    ">" @tag_name.inner)
  _+ @tag_name.inner
  close_tag: (jsx_closing_element
    "</" @tag_name.inner
    (_)* @tag_name.inner
    name: (identifier) @tag_name.outer))
