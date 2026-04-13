vim.g.mapleader = " "

local map = vim.keymap.set

-- Core options from config/default.nix and config/select.nix
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.virtualedit = "onemore"
vim.opt.whichwrap = "b,s,h,l,<,>"
vim.opt.wildmode = "longest,list"
vim.opt.keymodel = "startsel,stopsel"
vim.opt.selection = "exclusive"

if vim.env.SSH_TTY then
  vim.opt.clipboard = ""
else
  vim.opt.clipboard = "unnamedplus"
end

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local data = ev.data
    if not data or not data.spec then
      return
    end

    if data.spec.name == "telescope-fzf-native.nvim" and (data.kind == "install" or data.kind == "update") then
      if vim.fn.executable("make") == 1 then
        vim.system({ "make" }, { cwd = data.path }):wait()
      end
    end
  end,
})

-- Neovim 0.12 native package manager.
-- After the first start, restart Nvim once so newly installed plugins are on
-- disk and fully available. Update later with:
--   :lua vim.pack.update()
vim.pack.add({
  "https://github.com/catppuccin/nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/akinsho/toggleterm.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-telescope/telescope-file-browser.nvim",
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/nvim-telescope/telescope-ui-select.nvim",
  "https://github.com/debugloop/telescope-undo.nvim",
  "https://github.com/nvim-telescope/telescope-live-grep-args.nvim",
  "https://github.com/nvim-neo-tree/neo-tree.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/akinsho/bufferline.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/kdheepak/lazygit.nvim",
  "https://github.com/mg979/vim-visual-multi",
  "https://github.com/akinsho/git-conflict.nvim",
  "https://github.com/rmagatti/auto-session",
  "https://github.com/folke/noice.nvim",
  "https://github.com/rcarriga/nvim-notify",
  "https://github.com/kaarmu/typst.vim",
  "https://github.com/sindrets/diffview.nvim",
}, { confirm = false })

-- Plugin setup.
pcall(function()
  require("catppuccin").setup({
    transparent_background = true,
    flavour = "macchiato",
    integrations = {
      gitsigns = true,
      mini = {
        enabled = true,
        indentscope_color = "",
      },
      notify = false,
      neotree = true,
      treesitter = true,
    },
  })
  vim.cmd.colorscheme("catppuccin")
end)

pcall(function()
  require("notify").setup({
    background_colour = "#000000",
  })
  vim.notify = require("notify")
end)

pcall(function()
  require("noice").setup({})
end)

pcall(function()
  require("auto-session").setup({})
end)

pcall(function()
  require("gitsigns").setup({})
end)

pcall(function()
  require("toggleterm").setup({
    direction = "float",
    float_opts = {
      border = "curved",
    },
  })
end)

pcall(function()
  require("bufferline").setup({
    options = {
      always_show_bufferline = false,
      show_close_icon = false,
      show_buffer_close_icons = false,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-Tree",
          separator = true,
          text_align = "left",
        },
      },
    },
  })
end)

pcall(function()
  require("lualine").setup({
    options = {
      globalstatus = true,
    },
    sections = {
      lualine_c = {
        { "filename", path = 1 },
      },
    },
  })
end)

pcall(function()
  require("which-key").setup({})
  require("which-key").add({
    { "<leader>b", group = "Buffer" },
  })
end)

pcall(function()
  require("mini.comment").setup({
    mappings = {
      comment = "<C-_>",
      comment_line = "<C-_>",
      comment_visual = "<C-_>",
      textobject = "<C-_>",
    },
  })

  require("mini.move").setup({
    mappings = {
      left = "<M-Left>",
      right = "<M-Right>",
      down = "<M-Down>",
      up = "<M-Up>",
      line_left = "<S-M-Left>",
      line_right = "<S-M-Right>",
      line_down = "<S-M-Down>",
      line_up = "<S-M-Up>",
    },
    options = {
      reindent_linewise = false,
    },
  })

  require("mini.bufremove").setup()
end)

pcall(function()
  require("neo-tree").setup({
    close_if_last_window = false,
    filesystem = {
      filtered_items = {
        visible = true,
        always_show = { ".gitignore" },
        never_show = { ".DS_Store", "thumbs.db" },
      },
      hijack_netrw_behavior = "disabled",
      use_libuv_file_watcher = true,
    },
    window = {
      position = "left",
      mappings = {
        ["<left>"] = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" and node:is_expanded() then
            require("neo-tree.sources.filesystem").toggle_directory(state, node)
          else
            require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
          end
        end,
        ["<right>"] = function(state)
          local node = state.tree:get_node()
          if node.type == "directory" then
            if not node:is_expanded() then
              require("neo-tree.sources.filesystem").toggle_directory(state, node)
            elseif node:has_children() then
              require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
            end
          else
            require("neo-tree.sources.common.preview").show(state)
          end
        end,
      },
    },
  })
end)

pcall(function()
  require("telescope").setup({
    defaults = {
      vimgrep_arguments = {
        "rg",
        "-L",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--fixed-strings",
      },
      selection_caret = "  ",
      entry_prefix = "  ",
      layout_strategy = "flex",
      layout_config = {
        horizontal = {
          prompt_position = "top",
        },
      },
      sorting_strategy = "ascending",
      file_ignore_patterns = {
        "^.git/",
        "^.mypy_cache/",
        "^__pycache__/",
        "^output/",
        "^data/",
        "%.ipynb",
      },
      set_env = {
        COLORTERM = "truecolor",
      },
    },
    pickers = {
      colorscheme = {
        enable_preview = true,
      },
    },
    extensions = {
      file_browser = {
        hidden = true,
      },
      frecency = {
        auto_validate = false,
      },
      ["ui-select"] = require("telescope.themes").get_dropdown({}),
      undo = {
        side_by_side = true,
        layout_strategy = "vertical",
        layout_config = {
          preview_height = 0.8,
        },
      },
    },
  })

  pcall(require("telescope").load_extension, "file_browser")
  pcall(require("telescope").load_extension, "fzf")
  pcall(require("telescope").load_extension, "ui-select")
  pcall(require("telescope").load_extension, "undo")
  pcall(require("telescope").load_extension, "live_grep_args")
end)

pcall(function()
  require("nvim-treesitter.configs").setup({
    highlight = {
      enable = true,
    },
  })
end)

pcall(function()
  require("git-conflict").setup({
    default_mappings = true,
    disable_diagnostics = false,
    highlights = {
      current = "DiffText",
      incoming = "DiffAdd",
    },
    list_opener = "copen",
  })
end)

vim.g.VM_default_mappings = 0
vim.g.VM_maps = {
  ["Find Under"] = "<C-D>",
  ["Select All"] = "<C-M-D>",
  ["Goto Next"] = "]v",
  ["Goto Prev"] = "[v",
}
vim.g.VM_quit_after_leaving_insert_mode = 1

-- LSP setup for Neovim 0.12.
pcall(function()
  vim.lsp.config("jsonls", {})
  vim.lsp.enable("jsonls")

  vim.lsp.config("nil_ls", {
    settings = {
      ["nil"] = {
        formatting = {
          command = { "nixfmt" },
        },
      },
    },
  })
  vim.lsp.enable("nil_ls")

  vim.lsp.config("pyright", {})
  vim.lsp.enable("pyright")

  vim.lsp.config("pylsp", {
    settings = {
      pylsp = {
        plugins = {
          black = {
            enabled = true,
          },
        },
      },
    },
  })
  vim.lsp.enable("pylsp")
end)

-- Global keymaps from config/keymaps.nix and plugin modules.
map({ "n", "v" }, "<C-F>", "*''", { desc = "Find select", silent = true })
map({ "n", "v" }, "<C-H>", "cgn", { desc = "Replace" })
map({ "n", "v" }, "<C-A>", "<Esc>ggVG", { desc = "Select All" })
map({ "n", "i", "v" }, "<C-z>", "<cmd>undo<CR>", { desc = "Undo" })
map({ "n", "i", "v" }, "<C-y>", "<cmd>redo<CR>", { desc = "Redo" })
map({ "n", "i" }, "<C-s>", "<Esc>:update|checktime<CR>", { desc = "Save", silent = true })

map({ "n", "i" }, "<C-n>", function()
  vim.cmd("enew")
  local filename = vim.fn.input("Save as: ", "", "file")
  if filename ~= "" then
    vim.cmd("write " .. filename)
  else
    print("No filename entered. Buffer not saved.")
  end
end)

map("v", "<C-c>", '"+y')
map("v", "<C-x>", '"*d')

map("n", "<C-Up>", "3k")
map("n", "<C-Down>", "3j")

map({ "n", "i", "v" }, "<M-S-f>", function()
  vim.lsp.buf.format()
end)

map("n", "<M-Left>", "<C-w>h")
map("n", "<M-Down>", "<C-w>j")
map("n", "<M-Up>", "<C-w>k")
map("n", "<M-Right>", "<C-w>l")
map("n", "<leader>w", "<C-w>", { noremap = true, desc = "window" })

map("n", "<M-0>", "<cmd>tabclose<CR>")
map("n", "<M-1>", "1gt")
map("n", "<M-2>", "2gt")
map("n", "<M-3>", "3gt")
map("n", "<M-4>", "4gt")

map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next Buffer" })

map("n", "<leader>qq", "<cmd>qa!<CR>", { desc = "Quit All" })
map("n", "<leader>hh", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlight" })

map("n", "<S-Up>", "V<S-Up>", { silent = true })
map("n", "<S-Down>", "V<S-Down>", { silent = true })
map("n", "<S-Left>", "v<S-Left>", { silent = true })
map("n", "<S-Right>", "v<S-Right>", { silent = true })

map({ "n", "t" }, "<C-\\>", "<cmd>ToggleTerm<CR>", { desc = "Toggle Terminal" })

map("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "Toggle Pin" })
map("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", { desc = "Delete Non-Pinned Buffers" })
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", { desc = "Delete Other Buffers" })

map("n", "<leader>e", "<cmd>Neotree toggle reveal<CR>", { desc = "Toggle Neo-Tree" })

local builtin_ok, builtin = pcall(require, "telescope.builtin")
if builtin_ok then
  map("n", "<leader>fF", function()
    builtin.find_files({ hidden = true, no_ignore = true })
  end, { desc = "Find all files", silent = true })

  map("n", "<leader>fW", function()
    builtin.live_grep({
      additional_args = function(args)
        return vim.list_extend(args, { "--hidden", "--no-ignore" })
      end,
    })
  end, { desc = "Find words in all files", silent = true })

  map("n", "<leader>f?", function()
    builtin.live_grep({ grep_open_files = true })
  end, { desc = "Find words in all open buffers", silent = true })

  map("n", "<leader>f'", builtin.marks, { desc = "View marks" })
  map("n", "<leader>f/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in current buffer" })
  map("n", "<leader>f<CR>", builtin.resume, { desc = "Resume action" })
  map("n", "<leader>fa", builtin.autocommands, { desc = "View autocommands" })
  map("n", "<leader>fC", builtin.commands, { desc = "View commands" })
  map("n", "<leader>fb", builtin.buffers, { desc = "View buffers" })
  map("n", "<leader>fc", builtin.grep_string, { desc = "Grep string" })
  map("n", "<leader>fd", builtin.diagnostics, { desc = "View diagnostics" })
  map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
  map("n", "<leader><leader>", builtin.find_files, { desc = "Find files" })
  map("n", "<leader>fh", builtin.help_tags, { desc = "View help tags" })
  map("n", "<leader>fk", builtin.keymaps, { desc = "View keymaps" })
  map("n", "<leader>fm", builtin.man_pages, { desc = "View man pages" })
  map("n", "<leader>fo", builtin.oldfiles, { desc = "View old files" })
  map("n", "<leader>fr", builtin.registers, { desc = "View registers" })
  map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Search symbols" })
  map("n", "<leader>fq", builtin.quickfix, { desc = "Search quickfix" })
  map("n", "<leader>gB", builtin.git_branches, { desc = "View git branches" })
  map("n", "<leader>gC", builtin.git_commits, { desc = "View git commits" })
  map("n", "<leader>gs", builtin.git_status, { desc = "View git status" })
  map("n", "<leader>gS", builtin.git_stash, { desc = "View git stashes" })
end

map("n", "<leader>fu", "<cmd>Telescope undo<CR>", { desc = "List undo history" })
map("n", "<leader>fw", "<cmd>Telescope live_grep_args<CR>", { desc = "Live grep (args)" })

map("n", "<C-w><C-w>", function()
  local ok, bufremove = pcall(require, "mini.bufremove")
  if not ok then
    vim.cmd("bdelete")
    return
  end

  local bd = bufremove.delete
  if vim.bo.modified then
    local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
    if choice == 1 then
      vim.cmd.write()
      bd(0)
    elseif choice == 2 then
      bd(0, true)
    end
  else
    bd(0)
  end
end, { desc = "Remove Buffer" })

map("n", "<leader>hs", function()
  require("gitsigns").stage_hunk()
end, { desc = "Stage Hunk" })

map("n", "<leader>hr", function()
  require("gitsigns").reset_hunk()
end, { desc = "Reset Hunk" })

map("v", "<leader>hs", function()
  require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Stage Hunk" })

map("v", "<leader>hr", function()
  require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Reset Hunk" })

map("n", "<leader>bs", function()
  require("gitsigns").stage_buffer()
end, { desc = "Stage Buffer" })

map("n", "<leader>hu", function()
  require("gitsigns").undo_stage_hunk()
end, { desc = "Undo Stage Hunk" })

map("n", "<leader>br", function()
  require("gitsigns").reset_buffer()
end, { desc = "Reset Buffer" })

map("n", "<leader>hp", function()
  require("gitsigns").preview_hunk()
end, { desc = "Preview Hunk" })

map("n", "<leader>hb", function()
  require("gitsigns").blame_line({ full = true })
end, { desc = "Blame Line" })

map("n", "<leader>tb", function()
  require("gitsigns").toggle_current_line_blame()
end, { desc = "Toggle Current Line Blame" })

map("n", "<leader>hd", function()
  require("gitsigns").diffthis()
end, { desc = "Diff Current Buffer" })

map("n", "<leader>hD", function()
  require("gitsigns").diffthis("~")
end, { desc = "Diff Root" })

map("n", "<leader>td", function()
  require("gitsigns").toggle_deleted()
end, { desc = "Toggle Deleted" })

map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Toggle LazyGit" })

-- Autocmds from config/autocmd.nix
local help_group = vim.api.nvim_create_augroup("helpBuffer", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = help_group,
  pattern = "help",
  command = "only | set buflisted",
})

