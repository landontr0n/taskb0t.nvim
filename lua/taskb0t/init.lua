local M = {}

local api = vim.api

-- Module imports
local config = require('taskb0t.config')
local state = require('taskb0t.state')
local windows = require('taskb0t.ui.windows')
local files = require('taskb0t.files')

-- Setup function
M.setup = function(user_config)
    config.setup(user_config)
end

-- Find tasks (to be implemented)
M.find_tasks = function(dir)
    local vault_dir = dir or config.get().vault_dir
    vim.notify("Finding tasks in: " .. vault_dir, vim.log.levels.INFO)
    -- TODO: Implement task finding logic
end

-- Toggle task (to be implemented)
M.toggle_task = function(path, line)
    vim.notify(
        "Toggle task - path: " .. path .. " | line: " .. line,
        vim.log.levels.INFO
    )
    -- TODO: Implement task toggling logic
end

-- Update the picker view with current vault files
local function update_view()
    local buf_picker, _ = state.get_picker()

    if not buf_picker or not api.nvim_buf_is_valid(buf_picker) then
        vim.notify("Picker buffer not found", vim.log.levels.WARN)
        return
    end

    vim.bo[buf_picker].modifiable = true

    local result = files.get_files()
    if #result == 0 then
        table.insert(result, '')  -- Preserve layout if no results
    end

    api.nvim_buf_set_lines(buf_picker, 0, -1, false, result)
    vim.bo[buf_picker].modifiable = false
end

-- Open file in editor window
M.open_file = function()
    local file_path = api.nvim_get_current_line()

    if file_path == "" then
        return
    end

    if files.open_file(file_path) then
        set_editor_mappings()
    end
end

-- Create new file
M.create_file = function(dir)
    if files.create_file(dir) then
        update_view()
        vim.cmd("redraw")
    end
end

-- Delete file
M.delete_file = function()
    local file_path = api.nvim_get_current_line()

    if files.delete_file(file_path) then
        update_view()
    end
end

-- Close all windows
M.close_window = function()
    windows.close_all()
end

-- Toggle window focus
M.set_win = function(window_type)
    if window_type then
        windows.set_focus(window_type)
    else
        windows.toggle_focus()
    end
end

-- Navigate and auto-open files
M.editor_nav = function(direction)
    local _, win_picker = state.get_picker()

    if not win_picker or not api.nvim_win_is_valid(win_picker) then
        vim.notify("Picker window not found", vim.log.levels.WARN)
        return
    end

    local offset = direction == "down" and -1 or 1
    local current_pos = api.nvim_win_get_cursor(win_picker)[1]
    local new_pos = current_pos - offset

    -- Get total number of lines in picker buffer
    local buf_picker, _ = state.get_picker()
    local line_count = api.nvim_buf_line_count(buf_picker)

    -- Validate new position
    if new_pos < 1 or new_pos > line_count then
        return
    end

    local ok = pcall(api.nvim_win_set_cursor, win_picker, {new_pos, 0})
    if ok then
        M.open_file()
    end
end

-- Set picker window keymappings
local function set_picker_mappings()
    local buf_picker, _ = state.get_picker()

    if not buf_picker or not api.nvim_buf_is_valid(buf_picker) then
        return
    end

    local mappings = {
        ['<cr>'] = M.set_win,
        ['q'] = M.close_window,
        ['d'] = M.delete_file,
        ['c'] = M.create_file,
        ['j'] = function() M.editor_nav("down") end,
        ['k'] = function() M.editor_nav("up") end,
        ['l'] = M.set_win,
    }

    for key, func in pairs(mappings) do
        vim.keymap.set('n', key, func, {
            buffer = buf_picker,
            nowait = true,
            noremap = true,
            silent = true,
        })
    end
end

-- Set editor window keymappings
function set_editor_mappings()
    local buf_editor, _ = state.get_editor()

    if not buf_editor or not api.nvim_buf_is_valid(buf_editor) then
        return
    end

    vim.keymap.set('n', 'q', M.set_win, {
        buffer = buf_editor,
        nowait = true,
        noremap = true,
        silent = true,
    })
end

-- Main entry point
M.taskb0t = function()
    -- Create windows
    local buf_picker, win_picker = windows.create_picker()
    local buf_editor, win_editor = windows.create_editor()

    -- Store state
    state.set_picker(buf_picker, win_picker)
    state.set_editor(buf_editor, win_editor)

    -- Set up keymappings
    set_picker_mappings()
    set_editor_mappings()

    -- Update view and open first file
    update_view()
    windows.set_focus("picker")
    M.open_file()
end

return M
