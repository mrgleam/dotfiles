
local M = {}

function basename(filename)
    local without_ext = filename:gsub('%.%w+$', '')
    return string.match(without_ext, '[%w-]+$')
end

repos = {}

for filename in io.popen('ls ~/.config/nvim/lua/local_settings/repositories/*.lua'):lines() do
    local name = basename(filename)
    repos[name] = require("local_settings.repositories."..name)
end

function M.apply()
    local name = basename(vim.fn.getcwd())

    if repos[name] and repos[name].apply then
        repos[name].apply()
    end
end

function M.format()
    local name = basename(vim.fn.getcwd())

    if repos[name] and repos[name].format then
        repos[name].format()
    end
end

function M.on_new_config(lsp)
    local name = basename(vim.fn.getcwd())

    if repos[name] and repos[name].on_new_config then
        return (function (new_config)
                    return repos[name].on_new_config(lsp, new_config)
                end)
    end
end

return M
