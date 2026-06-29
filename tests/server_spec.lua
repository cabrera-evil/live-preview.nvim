local livepreview = require("livepreview")

print("Test module livepreview.server")

print()
print("start()")
local filepath = vim.fs.joinpath(vim.uv.cwd(), "README.md")
local started = false

vim.defer_fn(function()
	started = true
	livepreview.close()
	vim.cmd("qa!")
end, 100)

assert(livepreview.start(filepath, 5597), "should start the server")
assert(started == false, "start() should return without blocking Neovim's event loop")
assert(vim.wait(1000, function()
	return started
end), "Neovim's event loop should continue running after start()")
