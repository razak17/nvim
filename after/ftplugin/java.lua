if
  not ar.plugins.enable
  or ar.plugins.minimal
  or not ar.has('nvim-jdtls')
then
  return
end

-- Ref: https://github.com/guilhas07/.dotfiles/blob/main/nvim/.config/nvim/after/ftplugin/java.lua

local jdtls_path = ar.get_pkg_path('jdtls')
local jdtls_plugins_path = jdtls_path .. '/plugins'
local jdtls_config_path = jdtls_path .. '/config_linux'
local lombok_path = jdtls_path .. '/lombok.jar'
local path_to_jar = jdtls_plugins_path
  .. '/org.eclipse.equinox.launcher_1.7.0.v20250331-1702.jar'

local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/jdtls/' .. project_name

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-javaagent:' .. lombok_path,
    '-jar',
    path_to_jar,
    '-configuration',
    jdtls_config_path,
    '-data',
    workspace_dir,
  },
  settings = {
    java = {
      inlayHints = { enabled = 'all' },
      signatureHelp = { enabled = true },
      -- FIX(saveActions): when formatting removes imports if there are errors.
      -- saveActions = { organizeImports = true },
      -- cleanUp = {
      -- 	"qualifyMembers",
      -- 	"qualifyStaticMembers",
      -- 	"addOverride",
      -- 	"addDeprecated",
      -- 	"stringConcatToTextBlock",
      -- 	"invertEquals",
      -- 	"addFinalModifier",
      -- 	"instanceofPatternMatch",
      -- 	"lambdaExpression",
      -- 	"switchExpression",
      -- },
    },
  },
  capabilities = require('ar.servers').capabilities('jdtls'),
  root_dir = vim.fs.dirname(vim.fs.find(root_markers, { upward = true })[1]),
}

require('jdtls').start_or_attach(config)

ar.add_to_select_menu('lsp', {
  ['Java'] = function()
    ar.create_select_menu('Java', {
      ['Organize Imports'] = 'lua require("jdtls").organize_imports()',
      ['Extract Variable'] = function()
        ar.visual_cmd('lua require("jdtls").extract_variable()')
      end,
      ['Extract Constant'] = function()
        ar.visual_cmd('lua require("jdtls").extract_constant()')
      end,
      ['Extract Method'] = function()
        ar.visual_cmd('lua require("jdtls").extract_method()')
      end,
      ['Test Class'] = 'lua require("jdtls").test_class()',
      ['Test Nearest Method'] = 'lua require("jdtls").test_nearest_method()',
      ['Compile'] = 'JdtCompile',
      ['Set Runtime'] = 'JdtSetRuntime',
      ['Update Config'] = 'JdtUpdateConfig',
      ['Update Debug Config'] = 'JdtUpdateDebugConfig',
      ['Update Hotcode'] = 'JdtUpdateHotcode',
      ['Bytecode'] = 'JdtBytecode',
      ['Jol'] = 'JdtJol',
      ['JShell'] = 'JdtJshell',
      ['Restart'] = 'JdtRestart',
    })()
  end,
})
