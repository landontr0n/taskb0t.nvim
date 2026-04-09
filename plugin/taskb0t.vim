if exists('g:loaded_taskb0t')
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

" Initialize plugin with user config if provided
lua << EOF
    if vim.g.taskb0t_config then
        require('taskb0t').setup(vim.g.taskb0t_config)
    else
        require('taskb0t').setup()
    end
EOF

command! Taskb0tList lua require("taskb0t").taskb0t()
command! Taskb0tFindTasks lua require("taskb0t").find_tasks()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_taskb0t = 1
