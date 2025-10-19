return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio"
	},
	config = function()
		require("dapui").setup({})
		vim.keymap.set("n", "<F5>", function()
			require("dap").continue()
		end)
		vim.keymap.set("n", "<F10>", function()
			require("dap").step_over()
		end)
		vim.keymap.set("n", "<F11>", function()
			require("dap").step_into()
		end)
		vim.keymap.set("n", "<F12>", function()
			require("dap").step_out()
		end)
		vim.keymap.set("n", "<Leader>b", function()
			require("dap").toggle_breakpoint()
		end)
		vim.keymap.set("n", "<Leader>B", function()
			require("dap").set_breakpoint()
		end)
		vim.keymap.set("n", "<Leader>lp", function()
			require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
		end)
		vim.keymap.set("n", "<Leader>dr", function()
			require("dap").repl.open()
		end)
		vim.keymap.set("n", "<Leader>dl", function()
			require("dap").run_last()
		end)
		vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
			require("dap.ui.widgets").hover()
		end)
		vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
			require("dap.ui.widgets").preview()
		end)
		vim.keymap.set("n", "<Leader>df", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.frames)
		end)
		vim.keymap.set("n", "<Leader>ds", function()
			local widgets = require("dap.ui.widgets")
			widgets.centered_float(widgets.scopes)
		end)
		local dap, dapui = require("dap"), require("dapui")
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end
		dap.configurations.cpp = {
			{
				name = "Launch",
				type = "lldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},

				-- 💀
				-- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
				--
				--    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
				--
				-- Otherwise you might get the following error:
				--
				--    Error on launch: Failed to attach to the target process
				--
				-- But you should be aware of the implications:
				-- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
				-- runInTerminal = false,
			},
		}
		dap.configurations.rust = {
			{
				-- ... the previous config goes here ...,
				initCommands = function()
					-- Find out where to look for the pretty printer Python module.
					local rustc_sysroot = vim.fn.trim(vim.fn.system("rustc --print sysroot"))
					assert(
						vim.v.shell_error == 0,
						"failed to get rust sysroot using `rustc --print sysroot`: " .. rustc_sysroot
					)
					local script_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_lookup.py"
					local commands_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"

					-- The following is a table/list of lldb commands, which have a syntax
					-- similar to shell commands.
					--
					-- To see which command options are supported, you can run these commands
					-- in a shell:
					--
					--   * lldb --batch -o 'help command script import'
					--   * lldb --batch -o 'help command source'
					--
					-- Commands prefixed with `?` are quiet on success (nothing is written to
					-- debugger console if the command succeeds).
					--
					-- Prefixing a command with `!` enables error checking (if a command
					-- prefixed with `!` fails, subsequent commands will not be run).
					--
					-- NOTE: it is possible to put these commands inside the ~/.lldbinit
					-- config file instead, which would enable rust types globally for ALL
					-- lldb sessions (i.e. including those run outside of nvim). However,
					-- that may lead to conflicts when debugging other languages, as the type
					-- formatters are merely regex-matched against type names. Also note that
					-- .lldbinit doesn't support the `!` and `?` prefix shorthands.
					return {
						([[!command script import '%s']]):format(script_file),
						([[command source '%s']]):format(commands_file),
					}
				end,
				-- ...,
			},
		}
	end,
}
