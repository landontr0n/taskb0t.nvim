local M = {}

local api = vim.api

function M.get_files()
    local config = require('taskb0t.config').get()
    local vault_dir = config.vault_dir

    -- Validate vault directory exists
    if vim.fn.isdirectory(vault_dir) == 0 then
        if config.auto_create_vault then
            local ok = vim.fn.mkdir(vault_dir, "p")
            if ok == 0 then
                vim.notify(
                    "Vault directory not found and could not be created: " .. vault_dir,
                    vim.log.levels.ERROR
                )
                return {}
            end
        else
            vim.notify(
                "Vault directory not found: " .. vault_dir,
                vim.log.levels.ERROR
            )
            return {}
        end
    end

    -- Get files from vault
    local pattern = vault_dir .. "/*"
    local glob_result = vim.fn.glob(pattern, false, true)

    if not glob_result or #glob_result == 0 then
        return {}
    end

    return glob_result
end

function M.create_file(dir)
    local config = require('taskb0t.config').get()
    local user_input = vim.fn.input("New File Name: ")

    -- Validate input
    if user_input == "" or user_input:match("^%s*$") then
        vim.notify("Filename cannot be empty", vim.log.levels.ERROR)
        return false
    end

    if user_input:match("[/\\]") then
        vim.notify("Filename cannot contain path separators", vim.log.levels.ERROR)
        return false
    end

    if user_input:match("%.%.") then
        vim.notify("Filename cannot contain '..'", vim.log.levels.ERROR)
        return false
    end

    -- Remove .md extension if user provided it
    user_input = user_input:gsub("%.md$", "")

    local vault_dir = dir or config.vault_dir
    local filepath = vault_dir .. "/" .. user_input .. ".md"

    -- Resolve path and validate it's within vault
    local resolved_path = vim.fn.resolve(filepath)
    local resolved_vault = vim.fn.resolve(vault_dir)

    if not resolved_path:match("^" .. vim.fn.escape(resolved_vault, "^$()%.[]*+-?")) then
        vim.notify("Invalid file path", vim.log.levels.ERROR)
        return false
    end

    -- Check if file already exists
    if vim.fn.filereadable(filepath) == 1 then
        local choice = vim.fn.confirm(
            "File '" .. user_input .. ".md' already exists. Overwrite?",
            "&Yes\n&No",
            2
        )
        if choice ~= 1 then
            return false
        end
    end

    -- Write file
    local ok, err = pcall(vim.fn.writefile, {"# " .. user_input}, filepath)
    if not ok then
        vim.notify(
            "Failed to create file: " .. tostring(err),
            vim.log.levels.ERROR
        )
        return false
    end

    vim.notify("Created: " .. user_input .. ".md", vim.log.levels.INFO)
    return true
end

function M.delete_file(filepath)
    if not filepath or filepath == "" then
        vim.notify("No file selected", vim.log.levels.WARN)
        return false
    end

    local config = require('taskb0t.config').get()
    local filename = vim.fn.fnamemodify(filepath, ":t")

    -- Confirm deletion if configured
    if config.confirm_delete then
        local choice = vim.fn.confirm(
            "Delete file: " .. filename .. "?",
            "&Yes\n&No",
            2
        )
        if choice ~= 1 then
            return false
        end
    end

    -- Delete file
    local result = vim.fn.delete(filepath)
    if result == 0 then
        vim.notify("Deleted: " .. filename, vim.log.levels.INFO)
        return true
    else
        vim.notify(
            "Failed to delete file: " .. filename,
            vim.log.levels.ERROR
        )
        return false
    end
end

function M.open_file(filepath)
    local state = require('taskb0t.state')
    local _, win_editor = state.get_editor()

    if not filepath or filepath == "" then
        vim.notify("No file selected", vim.log.levels.WARN)
        return false
    end

    if not win_editor or not api.nvim_win_is_valid(win_editor) then
        vim.notify("Editor window not found", vim.log.levels.ERROR)
        return false
    end

    -- Escape filepath for safety
    local escaped_path = vim.fn.fnameescape(filepath)

    local ok, err = pcall(function()
        api.nvim_win_call(win_editor, function()
            vim.cmd.edit(escaped_path)
            local current_buf = api.nvim_win_get_buf(win_editor)
            local old_buf = state.get_editor()

            -- Delete old buffer if it's different and was a scratch buffer
            if old_buf and current_buf ~= old_buf and api.nvim_buf_is_valid(old_buf) then
                if vim.bo[old_buf].buftype == 'nofile' then
                    pcall(api.nvim_buf_delete, old_buf, { force = true })
                end
            end

            -- Update state with new buffer
            state.update_editor_buf(current_buf)
        end)
    end)

    if not ok then
        vim.notify(
            "Failed to open file: " .. tostring(err),
            vim.log.levels.ERROR
        )
        return false
    end

    return true
end

return M
