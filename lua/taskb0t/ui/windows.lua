local M = {}

local api = vim.api

local function calculate_window_dimensions(is_right_side)
    local config = require('taskb0t.config').get()
    local width = vim.o.columns
    local height = vim.o.lines

    local win_height = math.ceil(height * config.window_height_percent - 4)
    local win_width = math.ceil(width * config.window_width_percent)
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = is_right_side
        and math.ceil(width / 2 + 1)
        or math.ceil(width * 0.1 - 2)

    return {
        relative = "editor",
        border = "rounded",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
    }
end

local function create_window(title, is_right_side)
    local buf = api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].filetype = 'taskb0t'

    local opts = calculate_window_dimensions(is_right_side)
    opts.title = title
    opts.title_pos = "center"

    local win = api.nvim_open_win(buf, true, opts)
    vim.wo[win].cursorline = true

    return buf, win
end

function M.create_picker()
    return create_window("taskb0t", false)
end

function M.create_editor()
    return create_window("editor", true)
end

function M.close_all()
    local state = require('taskb0t.state')
    local buf_picker, win_picker = state.get_picker()
    local buf_editor, win_editor = state.get_editor()

    -- Cleanup editor window
    if win_editor and api.nvim_win_is_valid(win_editor) then
        local buf = api.nvim_win_get_buf(win_editor)

        -- Check for unsaved changes
        if buf and api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
            local choice = vim.fn.confirm(
                "Unsaved changes. Close anyway?",
                "&Yes\n&No",
                2
            )
            if choice ~= 1 then
                return false
            end
        end

        api.nvim_win_close(win_editor, true)
        if buf and api.nvim_buf_is_valid(buf) and buf ~= buf_editor then
            pcall(api.nvim_buf_delete, buf, { force = true })
        end
    end

    -- Cleanup picker window
    if win_picker and api.nvim_win_is_valid(win_picker) then
        api.nvim_win_close(win_picker, true)
    end

    -- Reset state
    state.reset()
    return true
end

function M.set_focus(window_type)
    local state = require('taskb0t.state')

    if not state.is_valid() then
        vim.notify("Windows not initialized", vim.log.levels.WARN)
        return
    end

    local _, win = window_type == "picker"
        and state.get_picker()
        or state.get_editor()

    if win and api.nvim_win_is_valid(win) then
        api.nvim_set_current_win(win)
    end
end

function M.toggle_focus()
    local state = require('taskb0t.state')

    if not state.is_valid() then
        vim.notify("Windows not initialized", vim.log.levels.WARN)
        return
    end

    local _, win_picker = state.get_picker()
    local _, win_editor = state.get_editor()
    local current_win = api.nvim_get_current_win()

    if current_win == win_picker then
        api.nvim_set_current_win(win_editor)
    else
        api.nvim_set_current_win(win_picker)
    end
end

return M
