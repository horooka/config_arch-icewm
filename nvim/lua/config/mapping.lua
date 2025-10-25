local k = vim.keymap

-- {"n", "v"}, "p", "paste to a next line"
-- {"n", "v"}, "s", "jump to a entered letter"

--neovide
if vim.g.neovide then
	vim.g.neovide_scale_factor = 1.0
	local change_scale_factor = function(delta)
		vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
	end
	k.set("n", "<C-=>", function()
		change_scale_factor(1.25)
	end)
	k.set("n", "<C-->", function()
		change_scale_factor(0.8)
	end)
	k.set("n", "<C-0>", function()
		vim.g.neovide_scale_factor = 1.0
	end)
end

--file
k.set({ "n", "i" }, ",q", "<Esc>:q!<CR>", { noremap = true, silent = true })
k.set({ "n", "i" }, ",e", "<Esc>:wq<CR>", { noremap = true, silent = true })
-- save and normal mode
k.set({ "n", "i", "v" }, ",s", "<Esc>:w<CR>", { noremap = true, silent = true })

--modes
-- {"i"}, "i", "insert mode"
k.set({ "n", "i" }, ",v", "<Esc>v", { noremap = true, silent = true })
k.set({ "n", "i" }, ",t", "<Esc>:!", { noremap = true, silent = true })
k.set({ "n", "i" }, ",r", "<Esc>:%s/", { noremap = true, silent = true })
k.set("v", ",r", "<Esc>:'<,'>s/", { noremap = true, silent = false })

--lines
k.set({ "n", "i" }, ",b", "<Esc>^i", { noremap = true, silent = true })
k.set({ "n", "i" }, ",a", "<Esc>A", { noremap = true, silent = true })
k.set({ "n", "i" }, ",l", "<Esc>V", { noremap = true, silent = true })
k.set({ "n", "i" }, ",d", "<Esc>Vx", { noremap = true, silent = true })
k.set({ "n", "i" }, ",c", "<Esc>Vy", { noremap = true, silent = true })
k.set({ "n", "i" }, ",g", "<Esc>V", { noremap = true, silent = true })
