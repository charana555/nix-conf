{ config, pkgs, lib, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      have_nerd_font = true;
    };

    opts = {
      number = true;
      mouse = "a";

      showmode = false;
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      list = true;
      listchars = "tab:» ,trail:·,nbsp:␣";
      inccommand = "split";
      cursorline = true;
      scrolloff = 10;
      confirm = true;
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;
    };

    keymaps = [
      { key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; mode = "n"; }
      { key = "<C-h>"; action = "<C-w><C-h>"; mode = "n"; options.desc = "Move focus to the left window"; }
      { key = "<C-l>"; action = "<C-w><C-l>"; mode = "n"; options.desc = "Move focus to the right window"; }
      { key = "<C-j>"; action = "<C-w><C-j>"; mode = "n"; options.desc = "Move focus to the lower window"; }
      { key = "<C-k>"; action = "<C-w><C-k>"; mode = "n"; options.desc = "Move focus to the upper window"; }
      { key = "<Esc><Esc>"; action = "<C-\\><C-n>"; mode = "t"; options.desc = "Exit terminal mode"; }
      { key = "<leader>q"; action = "<cmd>lua vim.diagnostic.setloclist()<CR>"; mode = "n"; options.desc = "Open diagnostic quickfix list"; }
      { key = "<leader>gg"; action = "<cmd>LazyGit<CR>"; mode = "n"; options.desc = "LazyGit"; }
      { key = "<leader>gf"; action = "<cmd>LazyGitFilterCurrentFile<CR>"; mode = "n"; options.desc = "LazyGit current file history"; }
      { key = "<leader>gl"; action = "<cmd>LazyGitFilter<CR>"; mode = "n"; options.desc = "LazyGit project commits"; }
      { key = "<leader>fh"; action = "<cmd>Telescope help_tags<CR>"; mode = "n"; options.desc = "Search Help"; }
      { key = "<leader>fk"; action = "<cmd>Telescope keymaps<CR>"; mode = "n"; options.desc = "Search Keymaps"; }
      { key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>"; mode = "n"; options.desc = "Search Files"; }
      { key = "<leader>ss"; action = "<cmd>Telescope builtin<CR>"; mode = "n"; options.desc = "Search Select Telescope"; }
      { key = "<leader>fw"; action = "<cmd>Telescope grep_string<CR>"; mode = [ "n" "v" ]; options.desc = "Search current Word"; }
      { key = "<leader>fg"; action = "<cmd>Telescope live_grep<CR>"; mode = "n"; options.desc = "Search by Grep"; }
      { key = "<leader>fd"; action = "<cmd>Telescope diagnostics<CR>"; mode = "n"; options.desc = "Search Diagnostics"; }
      { key = "<leader>fr"; action = "<cmd>Telescope resume<CR>"; mode = "n"; options.desc = "Search Resume"; }
      { key = "<leader>f."; action = "<cmd>Telescope oldfiles<CR>"; mode = "n"; options.desc = "Search Recent Files"; }
      { key = "<leader>fc"; action = "<cmd>Telescope commands<CR>"; mode = "n"; options.desc = "Search Commands"; }
      { key = "<leader><leader>"; action = "<cmd>Telescope buffers<CR>"; mode = "n"; options.desc = "Find existing buffers"; }
      { key = "<leader>e"; action = "<cmd>Neotree toggle<CR>"; mode = "n"; options.desc = "Toggle Explorer"; }
      { key = "<leader>E"; action = "<cmd>Neotree reveal<CR>"; mode = "n"; options.desc = "Reveal current file in Explorer"; }
      { key = "<leader>f"; action.__raw = "function() require('conform').format { async = true } end"; mode = ""; options.desc = "Format buffer"; }
    ];

    autoCmd = [
      {
        event = "TextYankPost";
        desc = "Highlight when yanking text";
        callback.__raw = "function() vim.hl.on_yank() end";
      }
      {
        event = "LspAttach";
        desc = "LSP keymaps and highlight on attach";
        callback.__raw = ''
          function(event)
            local buf = event.buf
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'
              vim.keymap.set(mode, keys, func, { buffer = buf, desc = 'LSP: ' .. desc })
            end

            map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
            map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
            map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = 'Goto References' })
            vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = 'Goto Implementation' })
            vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = 'Goto Definition' })
            vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
            vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
            vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = 'Goto Type Definition' })

            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client:supports_method('textDocument/documentHighlight', buf) then
              local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
              })
              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
              })
              vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                callback = function(event2)
                  vim.lsp.buf.clear_references()
                  vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                end,
              })
            end

            if client and client:supports_method('textDocument/inlayHint', buf) then
              map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf }) end, '[T]oggle Inlay [H]ints')
            end
          end
        '';
      }
    ];

    colorschemes.tokyonight = {
      enable = true;
      settings = {
        styles = {
          comments = { italic = false; };
        };
      };
    };

    plugins = {
      bufferline = {
        enable = true;
        settings = {
          options = {
            show_buffer_icons = true;
            show_buffer_close_icons = true;
            indicator = {
              style = "icon";
              icon = "▎";
            };
          };
        };
      };

      web-devicons = { enable = true; };

      guess-indent = { enable = true; };

      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add = { text = "+"; };
            change = { text = "~"; };
            delete = { text = "_"; };
            topdelete = { text = "‾"; };
            changedelete = { text = "~"; };
          };
          on_attach.__raw = ''
            function(bufnr)
              local gitsigns = require('gitsigns')

              local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
              end

              map('n', ']c', function()
                if vim.wo.diff then
                  vim.cmd.normal({ ']c', bang = true })
                else
                  gitsigns.nav_hunk('next')
                end
              end, 'Jump to next hunk')

              map('n', '[c', function()
                if vim.wo.diff then
                  vim.cmd.normal({ '[c', bang = true })
                else
                  gitsigns.nav_hunk('prev')
                end
              end, 'Jump to previous hunk')

              map('n', '<leader>hs', gitsigns.stage_hunk, 'Stage hunk')
              map('n', '<leader>hr', gitsigns.reset_hunk, 'Reset hunk')
              map('n', '<leader>hp', gitsigns.preview_hunk, 'Preview hunk')
              map('n', '<leader>hb', gitsigns.blame_line, 'Blame line')
              map('n', '<leader>hd', gitsigns.diffthis, 'Diff this')
              map('n', '<leader>hR', gitsigns.reset_buffer, 'Reset buffer')
              map('n', '<leader>hS', gitsigns.stage_buffer, 'Stage buffer')
              map('n', '<leader>hu', gitsigns.undo_stage_hunk, 'Undo stage hunk')

              map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, 'Select hunk')
            end
          '';
        };
      };

      which-key = {
        enable = true;
        settings = {
          delay = 0;
          icons = { mappings = true; };
          spec = [
            { __unkeyed-1 = "<leader>s"; group = "[S]earch"; mode = [ "n" "v" ]; }
            { __unkeyed-1 = "<leader>t"; group = "[T]oggle"; }
            { __unkeyed-1 = "<leader>h"; group = "Git [H]unk"; mode = [ "n" "v" ]; }
            { __unkeyed-1 = "<leader>g"; group = "[G]it"; }
            { __unkeyed-1 = "<leader>r"; group = "[R]est/HTTP"; }
            { __unkeyed-1 = "<leader>e"; group = "[E]xplorer"; }
            { __unkeyed-1 = "gr"; group = "LSP Actions"; mode = [ "n" ]; }
          ];
        };
      };

      telescope = {
        enable = true;
        extensions = {
          fzf-native = { enable = true; };
          ui-select = {
            enable = true;
            settings = { __raw = "require('telescope.themes').get_dropdown()"; };
          };
        };
      };

      todo-comments = {
        enable = true;
        settings = { signs = false; };
      };

      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          enable_diagnostics = true;
          enable_git_status = true;
          popup_border_style = "rounded";
          filesystem = {
            follow_current_file = { enabled = true; };
            hijack_netrw_behavior = "open_default";
            use_libuv_file_watcher = true;
            filtered_items = {
              visible = true;
              hide_dotfiles = false;
              hide_gitignored = true;
              hide_by_name = [ ".git" ".DS_Store" "thumbs.db" ];
            };
            window = {
              mappings = {
                "o" = "open";
                "h" = "close_node";
                "l" = "open";
                "<cr>" = "open";
                "<2-LeftMouse>" = "open";
                "a" = "add";
                "d" = "delete";
                "r" = "rename";
                "y" = "copy_to_clipboard";
                "x" = "cut_to_clipboard";
                "p" = "paste_from_clipboard";
                "c" = "copy";
                "m" = "move";
                "q" = "close_window";
                "R" = "refresh";
                "?" = "show_help";
                "<C-v>" = "open_vsplit";
                "<C-s>" = "open_split";
              };
            };
          };
          buffers = {
            follow_current_file = { enabled = true; };
            show_current_file = true;
          };
        };
      };

      mini-ai = {
        enable = true;
        settings = {
          mappings = {
            around_next = "aa";
            inside_next = "ii";
          };
          n_lines = 500;
        };
      };
      mini-surround = { enable = true; };
      mini-statusline = {
        enable = true;
        settings = {
          use_icons = true;
          section_location.__raw = "function() return '%2l:%-2v' end";
        };
      };

      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [ "bash" "c" "diff" "html" "lua" "luadoc" "markdown" "markdown_inline" "query" "vim" "vimdoc" "javascript" "typescript" "rust" "nix" ];
          auto_install = true;
        };
        highlight = {
          enable = true;
          additionalVimRegexHighlighting = [ "ruby" ];
        };
        indent = {
          enable = true;
          disable = [ "ruby" ];
        };
      };

      lsp = {
        enable = true;
        servers = {
          ts_ls = { enable = true; };
          lua_ls = {
            enable = true;
            settings = {
              Lua = {
                format = { enable = false; };
                runtime = { version = "LuaJIT"; };
                diagnostics = { globals = [ "vim" ]; };
                workspace = {
                  checkThirdParty = false;
                  library.__raw = "vim.api.nvim_get_runtime_file('', true)";
                };
              };
            };
          };
        };
      };

      mason = { enable = true; };
      mason-lspconfig = {
        enable = true;
        ensureInstalled = [ "ts_ls" "lua_ls" ];
      };

      fidget = { enable = true; };

      conform-nvim = {
        enable = true;
        settings = {
          notify_on_error = false;
          format_on_save = ''
            function(bufnr)
              local enabled_filetypes = {
                javascript = true,
                typescript = true,
                javascriptreact = true,
                typescriptreact = true,
              }
              if enabled_filetypes[vim.bo[bufnr].filetype] then
                return { timeout_ms = 500 }
              else
                return nil
              end
            end
          '';
          default_format_opts = { lsp_format = "fallback"; };
          formatters_by_ft = {
            javascript = [ "prettierd" "prettier" ];
            typescript = [ "prettierd" "prettier" ];
          };
        };
      };

      luasnip = {
        enable = true;
        settings = {
          history = true;
          delete_check_events = "TextChanged";
        };
      };

      lazygit = { enable = true; };
    };

    extraPlugins = with pkgs.vimPlugins; [
      kulala-nvim
      nvim-osc52
    ];

    extraConfigLua = ''
      require('osc52').setup {
        max_length = 0,
        silent = false,
        trim = false,
        tmux_passthrough = true,
      }

      vim.g.clipboard = {
        name = 'osc52',
        copy = {
          ['+'] = function(lines, _)
            require('osc52').copy(table.concat(lines, '\n'))
          end,
        },
        paste = {
          ['+'] = function() return nil end,
        },
      }

      vim.o.clipboard = 'unnamedplus'

      vim.diagnostic.config {
        update_in_insert = false,
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = { min = vim.diagnostic.severity.WARN } },
        virtual_text = true,
        virtual_lines = false,
        jump = { float = true },
      }

      require('kulala').setup({
        global_keymaps = true,
        global_keymaps_prefix = "<leader>R",
        kulala_keymaps_prefix = "",
      })

      -- Disable lua_ls formatting (stylua handles it)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "lua_ls" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end,
      })
    '';
  };
}
