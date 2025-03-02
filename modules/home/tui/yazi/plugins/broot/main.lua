-- Most of this was taken from https://github.com/sxyazi/yazi/blob/c65a14c0e650c92cce52fe507b9f84a873cae44d/yazi-plugin/preset/plugins/zoxide.lua
-- TODO: Use state instead of returns for some stuff maybe
local state = ya.sync(function(st)
	return {
		cwd = tostring(cx.active.current.cwd),
        target = st.target,
	}
end)

local set_state = ya.sync(function(st, empty) st.empty = empty end)

local function fail(s, ...)
	ya.notify { title = "Broot", content = string.format(s, ...), timeout = 5, level = "error" }
end

local get_file = ya.sync(function (st, filename)
    st.target = nil
    local file = io.open(filename, "r")
	if file == nil then
		return
	end

    st.target = file:read("*a") -- Read the full file
    file:close()

    if st.target == nil or st.target == "" then
        st.target = nil
        return st.target
    end

    os.remove(filename)
    return st.target
end)

local random_chars = function (amount)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    math.randomseed(os.time())
    for i = 1, amount do
        local char = math.random(1, #chars)
        result = result .. chars:sub(char, char)
    end
    return result
end

local function entry()
    local st = state()
    if st.cwd == nil then
        set_state(true)
    end
    
    local filename = "/tmp/yazi-broot." .. random_chars(8)

    local _permit = ya.hide()
    local child, err = Command("broot")
        :args({ "--conf", "@BROOT_CHOOSER_CONFIG@", "--verb-output", filename})
        :arg(st.cwd)
        :stdin(Command.INHERIT)
        :stdout(Command.PIPED)
        :stderr(Command.INHERIT)
        :spawn()

	if not child then
		return fail("Spawn `broot` failed with error code %s. Do you have it installed?", err)
	end

	local err = child:wait()
    local target = get_file(filename)

	if target ~= nil and target ~= "" then
        local file_cha = fs.cha(Url(target))
        if file_cha.is_dir then
		    ya.manager_emit("cd", { target })
        else
		    ya.manager_emit("reveal", { target })
        end
	end
end

return { entry = entry }
