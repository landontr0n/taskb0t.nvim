local M = {}

local api = vim.api

local state = {
    picker = { buf = nil, win = nil },
    editor = { buf = nil, win = nil },
    initialized = false,
}

function M.is_valid()
    return state.picker.win
        and api.nvim_win_is_valid(state.picker.win)
        and state.editor.win
        and api.nvim_win_is_valid(state.editor.win)
end

function M.is_initialized()
    return state.initialized
end

function M.set_picker(buf, win)
    state.picker = { buf = buf, win = win }
    state.initialized = true
end

function M.set_editor(buf, win)
    state.editor = { buf = buf, win = win }
end

function M.get_picker()
    return state.picker.buf, state.picker.win
end

function M.get_editor()
    return state.editor.buf, state.editor.win
end

function M.update_editor_buf(buf)
    state.editor.buf = buf
end

function M.reset()
    state = {
        picker = { buf = nil, win = nil },
        editor = { buf = nil, win = nil },
        initialized = false,
    }
end

return M
