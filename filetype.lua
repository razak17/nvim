if not vim.filetype then
  return
end

vim.g.do_filetype_lua = 1

vim.filetype.add({
  extension = {
    lock = "yaml",
  },
  filename = {
    [".gitignore"] = "conf",
    ["launch.json"] = "jsonc",
    ["Makefile.toml"] = "cargo-make",
    ["Podfile"] = "ruby",
    [".vimrc.local"] = "vim",
  },
  pattern = {
    ["*.graphql"] = "graphql",
    ["*.graphqls"] = "graphql",
    ["*.gql"] = "graphql",
    ["haproxy*.c*"] = "haproxy",
    ["*.hsc"] = "haskell",
    ["*.bpk"] = "haskell",
    ["*.hsig"] = "haskell",
    ["*.svelte"] = "svelte",
    ["*.sol"] = "solidity",
    ["*.gradle"] = "groovy",
    ["*.env.*"] = "env",
  },
})
