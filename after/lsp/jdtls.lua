local mason_root = vim.env.MASON or (vim.fn.stdpath('data') .. '/mason')

return {
  init_options = {
    bundles = {
      vim.fs.joinpath(
        mason_root,
        'share',
        'java-debug-adapter',
        'com.microsoft.java.debug.plugin.jar'
      ),
    },
  },
}
