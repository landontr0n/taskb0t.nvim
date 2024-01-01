local M = {}

-- eventual features...
-- tasks by tag
-- tag in frontmatter like task-tag
-- tasks by dir opt recursive
-- create favorites and have launcher like to pull up saved task contexts
-- toggle task

--local _config = {}

local api = vim.api
local buf_picker, buf_editor, win_picker, win_editor
local settings = vim.g.taskb0t_settings or {}

M.setup = function (config)
    --_config = config
    print("Config:", config)
end

M.find_tasks = function (dir)
    print("taskb0t.find_tasks: taskb0t vault dir:", dir or settings.vault_dir or '~/.config/taskb0t/vault/')
end

M.toggle_task = function (path, line)
    print("taskb0t.toggle_task: path: " .. path .. " | line: " .. line)
end

local function open_files_window()
  buf_picker = api.nvim_create_buf(false, true)

  api.nvim_buf_set_option(buf_picker, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf_picker, 'filetype', 'taskb0t')

  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.4)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width * 0.1) - 2)

  local opts = {
    relative = "editor",
    border = "rounded",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    title = "taskb0t",
    title_pos = "center"
  }

  win_picker = api.nvim_open_win(buf_picker, true, opts)

  api.nvim_win_set_option(win_picker, 'cursorline', true) -- it highlight line with the cursor on it

end

local function open_editor_window()
  buf_editor = api.nvim_create_buf(false, true)

  api.nvim_buf_set_option(buf_editor, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(buf_editor, 'filetype', 'taskb0t')

  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.4)
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width / 2) + 1)

  local opts = {
    relative = "editor",
    border = "rounded",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    title = "editor",
    title_pos = "center"
  }

  win_editor = api.nvim_open_win(buf_editor, true, opts)

  api.nvim_win_set_option(win_editor, 'cursorline', true) -- it highlight line with the cursor on it

end

local function open_navigator()
    open_files_window()
    open_editor_window()
end

local function get_files(dir)
    -- TODO: make sure this tripple or statement works
    -- Get all files and directories
    local content = vim.split(vim.fn.glob(dir or settings.vault_dir or '~/.config/taskb0t/vault' .. "/*"), '\n', {trimempty=true})

    return content
end

local function update_view()
  api.nvim_buf_set_option(buf_picker, 'modifiable', true)

  local result = get_files()
  if #result == 0 then table.insert(result, '') end -- add  an empty line to preserve layout if there is no results

  api.nvim_buf_set_lines(buf_picker, 0, -1, false, result)
  api.nvim_buf_set_option(buf_picker, 'modifiable', false)

  api.nvim_buf_set_option(buf_editor, 'modifiable', true)
  api.nvim_buf_set_lines(buf_editor, 0, -1, false, {"Editor"})
  api.nvim_buf_set_option(buf_editor, 'modifiable', false)
end

local function set_mappings()
  local picker_mappings = {
    ['<cr>'] = 'set_win()',
    q = 'close_window()',
    d = 'delete_file()',
    c = 'create_file()',
    j = 'editor_nav(\"down\")',
    k = 'editor_nav(\"up\")',
    l = 'set_win()'
  }

  for k,v in pairs(picker_mappings) do
    api.nvim_buf_set_keymap(buf_picker, 'n', k, ':lua require"taskb0t".'..v..'<cr>', {
        nowait = true, noremap = true, silent = true
      })
  end
end

local function set_editor_mappings()
  local editor_mappings = {
    q = 'set_win()'
  }

  for k,v in pairs(editor_mappings) do
    api.nvim_buf_set_keymap(buf_editor, 'n', k, ':lua require"taskb0t".'..v..'<cr>', {
        nowait = true, noremap = true, silent = true
      })
  end
end

M.create_file = function (dir)
    local user_input = vim.fn.input("New File Name: ")
    vim.fn.writefile({"# " .. user_input}, dir or settings.vault_dir or vim.fn.expand("~/.config/taskb0t/vault/") .. user_input .. '.md')
    update_view()
    api.nvim_command("echo '' | redraw")
    vim.api.nvim_echo({{"Created: " .. user_input, 'None'}}, true, {})
end

M.close_window = function ()
  -- TODO: make this work properly
  pcall(function ()
      api.nvim_win_call(win_editor, function ()
          api.nvim_command('bd')
      end)
      api.nvim_win_close(win_picker, true)
      api.nvim_win_close(win_editor, true)
  end)
end

M.open_file = function ()
  local str = api.nvim_get_current_line()

  pcall(function ()
      api.nvim_win_call(win_editor, function ()
          api.nvim_command('edit ' .. str)
          api.nvim_command('bd#')
      end)
  end)

  buf_editor = api.nvim_win_get_buf(win_editor)
  set_editor_mappings()
end

M.delete_file = function ()
  local str = api.nvim_get_current_line()
  local user_input = vim.fn.input("Are you sure you want to delete: " .. str .. " ? [y/N] : ")
  api.nvim_command("echo '' | redraw")
  if user_input == "y" then
      vim.fn.delete(str)
      update_view()
      vim.api.nvim_echo({{"Deleted: " .. str}}, true, {})
  end
end

M.set_win = function (window)
    -- TODO: I'm assuming I can do better than this...
    if window == nil then
        local current_win = api.nvim_get_current_win()
        if current_win == win_picker then
            window = win_editor
        else
            window = win_picker
        end
    end

    api.nvim_set_current_win(window)
end

M.editor_nav = function (direction)
  local diff = 1
  if direction == "down" then
    diff = -1
  end

  local new_pos = api.nvim_win_get_cursor(win_picker)[1] - diff
  pcall(function ()
      api.nvim_win_set_cursor(win_picker, {new_pos, 0})
      M.open_file()
  end)
end

M.taskb0t = function ()
    open_navigator()
    set_mappings()
    set_editor_mappings()
    update_view()
    M.set_win(win_picker)
    M.open_file()
end

return M
