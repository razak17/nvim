local g = vim.g

g.rooter_change_directory_for_non_project_files = 'current'
g.rooter_patterns = {'=src', '.git', 'Makefile', '*.sln', 'build/env.sh'}
g.rooter_manual_only = 1
g.rooter_silent_chdir = 1
g.rooter_resolve_links = 1
