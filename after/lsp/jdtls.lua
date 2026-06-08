local mason_root = vim.env.MASON or (fn.stdpath('data') .. '/mason')

return {
  init_options = {
    bundles = {
      join_paths(
        mason_root,
        'share',
        'java-debug-adapter',
        'com.microsoft.java.debug.plugin.jar'
      ),
    },
  },
}
