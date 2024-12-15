return {
	-- lazy.nvim
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			--"rcarriga/nvim-notify",
		}
	},
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- set this if you want to always pull the latest change
		opts = {
			-- add any opts here
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				'MeanderingProgrammer/render-markdown.nvim',
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
	{
		"lvimuser/lsp-inlayhints.nvim",
		lazy = true,
	},
	{
		"CRAG666/code_runner.nvim",
		config = function()
			require("code_runner").setup {
				filetype = {
					c = function(...)
						-- Get the absolute path of the current file
						local dir = vim.fn.expand "%:p:h"
						local c_base = {
							"cd " .. dir .. " &&", -- Change to the directory of the current file
							"make fclean && make &&",
						}

						-- Directly extract the NAME from the Makefile if defined
						local program_name =
							vim.fn.system "grep -oP '^NAME\\s*=\\s*.*' Makefile | grep -oP '(?<=\\=).*'"
						program_name = program_name:gsub("%s+", "") -- Remove any trailing whitespace

						if program_name == "" then
							vim.notify("Program name not found", vim.log.levels.ERROR)
							return
						end

						vim.ui.input({ prompt = "Add more args:" }, function(input)
							-- Add the program name and input arguments to the command
							table.insert(c_base, "./" .. program_name .. " " .. input)
							local command = table.concat(c_base, " ")

							-- Open a floating terminal and send the command
							local term_id = require("nvchad.term").toggle { pos = "float", id = "floatTerm" }

							-- Wait for the terminal to open and then send the command
							vim.cmd "redraw"
							vim.defer_fn(function()
								local term_buf = vim.api.nvim_get_current_buf()
								local job_id = vim.b.terminal_job_id

								if job_id then
									vim.api.nvim_chan_send(job_id, command .. "\n")
								else
									vim.notify("Failed to send command to terminal", vim.log.levels.ERROR)
								end
							end, 100) -- Adjust delay as needed
						end)
					end,
				},
			}
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	{
		"Isrothy/neominimap.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter", --- Recommended
		},
		enabled = false,
		lazy = false,         -- NOTE: NO NEED to Lazy load
		init = function()
			vim.opt.wrap = false -- Recommended
			vim.opt.sidescrolloff = 36 -- It's recommended to set a large value
			vim.g.neominimap = {
				auto_enable = true,
			}
		end,
	},
	{
		"folke/twilight.nvim",
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
		config = function()
			require("twilight").setup {
				{
					dimming = {
						alpha = 0.25, -- amount of dimming
						-- we try to get the foreground from the highlight groups or fallback color
						color = { "Normal", "#ffffff" },
						term_bg = "#000000", -- if guibg=NONE, this will be used to calculate text color
						inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
					},
					context = 10, -- amount of lines we will try to show around the current line
					treesitter = true, -- use treesitter when available for the filetype
					-- treesitter is used to automatically expand the visible text,
					-- but you can further control the types of nodes that should always be fully expanded
					expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
						"function",
						"method",
						"table",
						"if_statement",
					},
					exclude = {}, -- exclude these filetypes
				},
			}
		end,
	},
	{
		"stevearc/conform.nvim",
		-- event = 'BufWritePre', -- uncomment for format on save
		opts = require "configs.conform",
	},

	-- These are some examples, uncomment them if you want to see them work!
	{
		"neovim/nvim-lspconfig",
		config = function()
			require "configs.lspconfig"
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"vim",
				"lua",
				"vimdoc",
				"html",
				"css",
			},
		},
	},
	{
		"Diogo-ss/42-header.nvim",
		cmd = { "Stdheader" },
		keys = { "<F1>" },
		opts = {
			default_map = true,                 -- Default mapping <F1> in normal mode.
			auto_update = true,                 -- Update header when saving.
			user = "ferafano",                  -- Your user.
			mail = "ferafano@student.42antananarivo.mg", -- Your mail.
			-- add other options.
		},
		config = function(_, opts)
			require("42header").setup(opts)
		end,
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			bigfile = { enabled = true },
			dashboard = {
				enabled = true,
				sections = {
					{ section = "header" },
					{
						pane = 2,
						section = "terminal",
						cmd = "~/.local/bin/colorscript -e zwaves",
						height = 5,
						padding = 1,
					},
					{ section = "keys",  gap = 1, padding = 1 },
					{
						pane = 2,
						icon = " ",
						desc = "Browse Repo",
						padding = 1,
						key = "b",
						action = function()
							Snacks.gitbrowse()
						end,
					},
					function()
						local in_git = Snacks.git.get_root() ~= nil
						local cmds = {
							{
								title = "Notifications",
								cmd = "gh notify -s -a -n5",
								action = function()
									vim.ui.open("https://github.com/notifications")
								end,
								key = "n",
								icon = " ",
								height = 5,
								enabled = true,
							},
							{
								title = "Open Issues",
								cmd = "gh issue list -L 3",
								key = "i",
								action = function()
									vim.fn.jobstart("gh issue list --web", { detach = true })
								end,
								icon = " ",
								height = 7,
							},
							{
								icon = " ",
								title = "Open PRs",
								cmd = "gh pr list -L 3",
								key = "p",
								action = function()
									vim.fn.jobstart("gh pr list --web", { detach = true })
								end,
								height = 7,
							},
							{
								icon = " ",
								title = "Git Status",
								cmd = "hub --no-pager diff --stat -B -M -C",
								height = 10,
							},
						}
						return vim.tbl_map(function(cmd)
							return vim.tbl_extend("force", {
								pane = 2,
								section = "terminal",
								enabled = in_git,
								padding = 1,
								ttl = 5 * 60,
								indent = 3,
							}, cmd)
						end, cmds)
					end,
					{ section = "startup" },
				},
			},
			indent = { enabled = true },
			input = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
		},
	}
}
