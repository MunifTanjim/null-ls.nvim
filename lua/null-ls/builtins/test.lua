local u = require("null-ls.utils")
local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local api = vim.api

local M = {}

M.toggle_line_comment = {
    method = methods.internal.CODE_ACTION,
    filetypes = { "*" },
    generator = {
        fn = function(params)
            local bufnr = api.nvim_get_current_buf()
            local commentstring = api.nvim_buf_get_option(bufnr, "commentstring")
            local raw_commentstring = u.string.replace(commentstring, "%s", "")
            local line = params.content[params.row]

            local has_comment = string.find(line, raw_commentstring, nil, true)
            if has_comment then
                return {
                    {
                        title = "Uncomment line",
                        action = function()
                            api.nvim_buf_set_lines(bufnr, params.row - 1, params.row, false, {
                                u.string.replace(line, raw_commentstring, ""),
                            })
                        end,
                    },
                }
            end

            return {
                {
                    title = "Comment line",
                    action = function()
                        api.nvim_buf_set_lines(bufnr, params.row - 1, params.row, false, {
                            string.format(commentstring, line),
                        })
                    end,
                },
            }
        end,
    },
}

M.mock_code_action = {
    method = methods.internal.CODE_ACTION,
    generator = {
        fn = function()
            return {
                {
                    title = "Mock action",
                    action = function()
                        print("I am a mock action!")
                    end,
                },
            }
        end,
    },
    filetypes = { "lua" },
}

M.slow_code_action = h.make_builtin({
    method = methods.internal.CODE_ACTION,
    filetypes = { "lua" },
    generator_opts = {
        command = "bash",
        args = { "./test/scripts/sleep-and-echo.sh" },
        timeout = 100,
        on_output = function(params, done)
            if not params.output then
                return done()
            end

            return done({
                {
                    title = "Slow mock action",
                    action = function()
                        print("I took too long!")
                    end,
                },
            })
        end,
    },
    factory = h.generator_factory,
})

M.cached_code_action = h.make_builtin({
    method = methods.internal.CODE_ACTION,
    filetypes = { "lua" },
    generator_opts = {
        command = "ls",
        on_output = function(params, done)
            return done({
                {
                    title = params._null_ls_cached and "Cached" or "Not cached",
                    action = function()
                    end,
                },
            })
        end,
        use_cache = true,
    },
    factory = h.generator_factory,
})

M.mock_diagnostics = {
    method = methods.internal.DIAGNOSTICS,
    generator = {
        fn = function()
            return {
                {
                    col = 1,
                    row = 1,
                    message = "There is something wrong with this file!",
                    severity = 1,
                    source = "mock-diagnostics",
                },
            }
        end,
    },
    filetypes = { "markdown" },
}

return M
