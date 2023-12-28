local M = {}

-- eventual features...
-- tasks by tag
-- tag in frontmatter like task-tag
-- tasks by dir opt recursive
-- create quick acess task books
-- create favorites and have aluancher like to pull up saved task contexts
-- toggle task
--
-- nvim_get_keymap
-- vim.keymap.set(...)
-- vim.api

local _config = {}

M.setup = function (config)
    _config = config
    print("Config:", config)
end

M.find_tasks = function (dir)
    -- print("taskb0t.find_tasks: dir:", dir)

    local settings = vim.g.taskb0t_settings or {}

    print("taskb0t.find_tasks: taskb0t vault dir:", settings.vault_dir or '~/.config/taskb0t/vault/')
end

M.toggle_task = function (path, line)
    print("taskb0t.toggle_task: path: " .. path .. " | line: " .. line)
end


local api = vim.api
local buf, win

local function open_window()
  buf = api.nvim_create_buf(false, true)

  api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf, 'filetype', 'taskb0t')

  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    title = "taskb0t",
    title_pos = "center",
    border = "double"
  }

  win = api.nvim_open_win(buf, true, opts)

  api.nvim_win_set_option(win, 'cursorline', true) -- it highlight line with the cursor on it

end

local function get_files(dir)
    -- local cwDir = vim.fn.getcwd()
    local settings = vim.g.taskb0t_settings or {}

    -- TODO: make sure this tripple or statement works
    -- Get all files and directories
    local content = vim.split(vim.fn.glob(dir or settings.vault_dir or '~/.config/taskb0t/vault' .. "/*"), '\n', {trimempty=true})

    return content
end

local function update_view()
  api.nvim_buf_set_option(buf, 'modifiable', true)

  local result = get_files()
  if #result == 0 then table.insert(result, '') end -- add  an empty line to preserve layout if there is no results

  api.nvim_buf_set_lines(buf, 0, -1, false, result)
  api.nvim_buf_set_option(buf, 'modifiable', false)
end

M.close_window = function ()
  -- TODO: make this work properly
  api.nvim_win_close(win, true)
end

M.open_file = function ()
  local str = api.nvim_get_current_line()
  M.close_window()
  -- TODO: make me open the file, maybe
  --api.nvim_command('edit ' ..str )
  print("taskb0t.open_file")
end

local function set_mappings()
  local mappings = {
    ['<cr>'] = 'open_file()',
    q = 'close_window()'
  }

  for k,v in pairs(mappings) do
    api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"taskb0t".'..v..'<cr>', {
        nowait = true, noremap = true, silent = true
      })
  end
end

M.taskb0t = function ()
    open_window()
    set_mappings()
    update_view()
end

-- test run stuff w/ source %
M.taskb0t()

return M
