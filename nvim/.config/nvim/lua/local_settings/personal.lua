local M = {}

function M.format()
    vim.lsp.buf.formatting_sync()
end

function M.on_new_config(lsp, new_config)
    if lsp == 'hls' then
        new_config.settings.haskell.formattingProvider = "fourmolu"
    end
end

return M
