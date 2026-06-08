if not ar.plugins.enable or ar.plugins.minimal or not ar.has('nvim-jdtls') then
  return
end

ar.add_to_select('lsp', {
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
