local M = {}

local default_config = {
    delay = 500,
    enabled = true
}

local state = {
    config = default_config,
    highlight_group = nil,
    highlight_timer = nil,
    is_setup = false
}

local function clear_timer()
    if state.highlight_timer then
        vim.fn.timer_stop(state.highlight_timer)
        state.highlight_timer = nil
    end
end

local function has_document_highlight_support()
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
        if client.supports_method("textDocument/documentHighlight") then
            return true
        end
    end
    return false
end

local function highlight_document()
    if not state.config.enabled or not has_document_highlight_support() then
        return
    end

    clear_timer()

    state.highlight_timer = vim.fn.timer_start(state.config.delay, function()
        if has_document_highlight_support() then
            vim.lsp.buf.document_highlight()
        end
        state.highlight_timer = nil
    end)
end

local function clear_document_highlight()
    clear_timer()

    if has_document_highlight_support() then
        vim.lsp.buf.clear_references()
    end
end

local function setup_autocommands()
    if state.highlight_group then
        vim.api.nvim_del_augroup_by_id(state.highlight_group)
    end

    state.highlight_group = vim.api.nvim_create_augroup("DocumentHighlightGroup", { clear = true })

    vim.api.nvim_create_autocmd("CursorHold", {
        desc = "Highlight similar words",
        group = state.highlight_group,
        pattern = "*",
        callback = highlight_document,
    })

    vim.api.nvim_create_autocmd("CursorMoved", {
        desc = "Clear similar word highlights",
        group = state.highlight_group,
        pattern = "*",
        callback = clear_document_highlight,
    })
end

function M.setup(opts)
    vim.print('rhydiian setup')
    opts = opts or {}
    state.config = vim.tbl_deep_extend("force", default_config, opts)
    setup_autocommands()
    state.is_setup = true
end

function M.enable()
    state.config.enabled = true
    if state.is_setup then
        setup_autocommands()
    end
end

function M.disable()
    state.config.enabled = false
    clear_timer()
    clear_document_highlight()
end

function M.toggle()
    if state.config.enabled then
        M.disable()
    else
        M.enable()
    end
end

function M.get_config()
    return vim.deepcopy(state.config)
end

function M.update_config(opts)
    state.config = vim.tbl_deep_extend("force", state.config, opts)
    if state.is_setup then
        setup_autocommands()
    end
end

return M
