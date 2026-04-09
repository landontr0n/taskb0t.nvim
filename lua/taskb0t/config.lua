local M = {}

local defaults = {
    vault_dir = vim.fn.expand("~/.config/taskb0t/vault"),
    window_width_percent = 0.4,
    window_height_percent = 0.8,
    auto_create_vault = true,
    confirm_delete = true,
}

local config = vim.deepcopy(defaults)

function M.setup(user_config)
    config = vim.tbl_deep_extend("force", defaults, user_config or {})

    -- Validate and expand vault_dir
    config.vault_dir = vim.fn.expand(config.vault_dir)

    -- Create vault if needed
    if config.auto_create_vault and vim.fn.isdirectory(config.vault_dir) == 0 then
        local ok = vim.fn.mkdir(config.vault_dir, "p")
        if ok == 0 then
            vim.notify(
                "Failed to create vault directory: " .. config.vault_dir,
                vim.log.levels.ERROR
            )
        end
    end

    return config
end

function M.get()
    return config
end

function M.reset()
    config = vim.deepcopy(defaults)
end

return M
