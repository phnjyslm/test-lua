local extra_log = function(fn,...)
	local data = { ... }
	
	for i=1, #data do
		if i==1 then
			local clr = {
				{ 171,217,53 },
				{ 255, 0, 0 },
			}

			client.color_log(clr[fn][1], clr[fn][2], clr[fn][3], '[gamesense] \0')
		end

		client.color_log(data[i][1], data[i][2], data[i][3],  string.format('%s\0', data[i][4]))
        
        if i == #data then
            client.color_log(255, 255, 255, ' ')
        end
	end
end
--[[ local debug_color = ui.new_checkbox("LUA", "A", "Debug log color")
local color = ui.new_color_picker("lua","a","11",255,255,255,255)
client.set_event_callback("paint", function()
    local r,g,b = ui.get(color)
    if ui.get(debug_color) then
        client.color_log(r, g, b, "Testing msg")
    end
end) ]]

local function aim_miss(e)
    local name = entity.get_player_name(e.target)
    local hitgroup_names = { "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?" }
    local group = hitgroup_names[e.hitgroup + 1] or "?"
    local resolver = ""
    if e.reason == "?" then
    	resolver = "resolver"
    else
    	resolver = e.reason
    end
    local health = entity.get_prop(e.target, "m_iHealth")
    extra_log(1,{251,251,149,resolver},{255,255,255," - "},{255,5,5,name},{255,255,255," miss in the "},{168,230,255,group},{255,255,255," | health: "..health.." hitchance: "..e.hit_chance.."%"})
--[[     AB D9 35 FF ]]
end

client.set_event_callback("aim_miss", aim_miss)


