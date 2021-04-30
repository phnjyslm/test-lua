local hit_label = ui.new_label("Lua","a", "Hit color")
local hit_color = ui.new_color_picker("Lua","a", "Color_hit", 2,255, 2, 255)

local miss_label = ui.new_label("Lua","a", "Miss color")
local miss_color = ui.new_color_picker("Lua","a", "Color_miss", 255,255, 255, 255)

local extend_anim = ui.new_multiselect("Lua","a", "Animation effects",{"Death line","Log alpha","Hit arrow","Custom arrow style"})

local death_line_label = ui.new_label("Lua","a", "Death line color")
local death_line_color = ui.new_color_picker("Lua","a", "Death_line", 255, 255, 255, 255)

local arrow_hit_style = ui.new_combobox("Lua","a", "Arrow hit style", {"☑ ","✔ ","✓ ","√ ","☢ ","☯ ","☘ ","❀ ","☹ "})
local arrow_miss_style = ui.new_combobox("Lua","a", "Arrow miss style", {"☒ ","✘ ","✗ ","× ","⨯ ","× ","☢ ","☯ ","☘ ","❀ ","☹ "})

local arrow_hit_label = ui.new_label("Lua","a", "Hit arrow color")
local arrow_hit_color = ui.new_color_picker("Lua","a", "Hit_arrow", 255, 255, 255, 255)

local arrow_miss_label = ui.new_label("Lua","a", "Miss arrow color")
local arrow_miss_color = ui.new_color_picker("Lua","a", "Miss_arrow", 255, 255, 255, 255)

local hit_info = {
    last_damage = 0
}
local function contains(table, val)if #table > 0 then for i=1, #table do if table[i] == val then return true end end end return false end
local notify = (function()
    local notify = {callback_registered = false, maximum_count = 7, data = {}}
    function notify:register_callback()
        if self.callback_registered then return end
        client.set_event_callback('paint_ui', function()
            local screen = {client.screen_size()}
            local d = 5;
            local data = self.data;
            for f = #data, 1, -1 do
                data[f].time = data[f].time - globals.frametime()
                local alpha, h = 255, 0;
                local _data = data[f]
                if _data.time < 0 then
                    table.remove(data, f)
                else
                    local time_diff = _data.def_time - _data.time;
                    local time_diff = time_diff > 1 and 1 or time_diff;
                    if _data.time < 0.5 or time_diff < 0.5 then
                        h = (time_diff < 1 and time_diff or _data.time) / 0.5;
                        alpha = h * 255;
                        if h < 0.2 then
                            d = d + 15 * (1.0 - h / 0.2)
                        end
                    end
                    local text_data = {renderer.measure_text("b", _data.draw)}
                    local screen_data = {8, 20 + d}
                    --"Death line","Log alpha","Hit arrow","Custom arrow style"

                    local active_alpha = contains(ui.get(extend_anim),"Log alpha")
                    local death_line = contains(ui.get(extend_anim),"Death line")
                    local active_arrow = contains(ui.get(extend_anim),"Hit arrow")
                    local active_arrow_style = contains(ui.get(extend_anim),"Custom arrow style")

                    local h_r,h_g,h_b,h_a = 0,0,0,0
                    local m_r,m_g,m_b,m_a = 0,0,0,0
                    local a_h_r,a_h_g,a_h_b,a_h_a = 0,0,0,0
                    local a_m_r,a_m_g,a_m_b,a_m_a = 0,0,0,0
                    local d_r,d_g,d_b,d_a = 0,0,0,0

                    local arrow_style = _data.miss and "F" or "t"

                    if active_alpha then
                        h_r,h_g,h_b,h_a = ui.get(hit_color)
                        m_r,m_g,m_b,m_a = ui.get(miss_color)
                        a_h_r,a_h_g,a_h_b,a_h_a = ui.get(arrow_hit_color)
                        a_m_r,a_m_g,a_m_b,a_m_a = ui.get(arrow_miss_color)
                        d_r,d_g,d_b,d_a = ui.get(death_line_color)
                        h_a,m_a,a_h_a,a_m_a,d_a = alpha,alpha,alpha,alpha,alpha
                    else
                        h_r,h_g,h_b,h_a = ui.get(hit_color)
                        m_r,m_g,m_b,m_a = ui.get(miss_color)
                        a_h_r,a_h_g,a_h_b,a_h_a = ui.get(arrow_hit_color)
                        a_m_r,a_m_g,a_m_b,a_m_a = ui.get(arrow_miss_color)
                        d_r,d_g,d_b,d_a = ui.get(death_line_color)
                    end
                    local w,h = renderer.measure_text("b", arrow_style.._data.draw)
                    if active_arrow_style  then
                        if not _data.miss then
                            arrow_style = ui.get(arrow_hit_style)
                        else
                            arrow_style = ui.get(arrow_miss_style)
                        end
                    end
                    local arrow_w,arrow_h = 0,0

                    if _data.miss then
                        if active_arrow then
                            arrow_w,arrow_h = renderer.measure_text("b", arrow_style)
                            renderer.text(screen_data[1], screen_data[2], a_m_r,a_m_g,a_m_b,a_m_a, 'b', nil,arrow_style)
                            renderer.text(screen_data[1]+arrow_w, screen_data[2], m_r,m_g,m_b,m_a, 'b', nil,_data.draw)
                        else
                            renderer.text(screen_data[1], screen_data[2], m_r,m_g,m_b,m_a, 'b', nil,_data.draw)
                        end
                    else
                        if active_arrow then
                            arrow_w,arrow_h = renderer.measure_text("b", arrow_style)
                            renderer.text(screen_data[1], screen_data[2], a_h_r,a_h_g,a_h_b,a_h_a, 'b', nil,arrow_style)
                            renderer.text(screen_data[1]+arrow_w, screen_data[2], h_r,h_g,h_b,h_a, 'b', nil,_data.draw)
                        else
                            renderer.text(screen_data[1], screen_data[2], h_r,h_g,h_b,h_a, 'b', nil,_data.draw)
                        end
                    end
                    --[[ renderer.text(screen_data[1], screen_data[2], 255,255,255, alpha, 'b', nil,_data.draw.."✔".."✘".."☑") ]]
                    if death_line and not entity.is_alive(_data.index) then
                        renderer.line(screen_data[1], screen_data[2]+h/2+1, screen_data[1]+w+8, screen_data[2]+h/2+1, d_r,d_g,d_b,d_a)
                    end
                    d = d + text_data[2]
                end
            end
            self.callback_registered = true
        end)
    end
    function notify:paint(time, text, idx, mis)
        
        local timer = tonumber(time) + 1;
        for f = self.maximum_count, 2, -1 do
            self.data[f] = self.data[f - 1]
        end
        self.data[1] = {time = timer, def_time = timer, draw = text,index = idx,miss = mis}
--[[         print(index) ]]
        self:register_callback()
    end
    return notify
end)()

local function aim_miss(e)
    local name = entity.get_player_name(e.target)
    local hitgroup_names = { "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?" }
    local group = hitgroup_names[e.hitgroup + 1] or "?"
    local resolver = ""
    if e.reason == "?" then
    	resolver = "resolver?"
    else
    	resolver = e.reason
    end
    
    notify:paint(3, "miss shot "..name.." hb: ( "..group.." ) info: ( "..resolver.." ) hc: ( "..e.hit_chance.."% )",e.target,true)
end
local function player_hurt(e)
    local attacker_id = client.userid_to_entindex(e.attacker)

    if attacker_id == nil then
        return
    end

    if attacker_id ~= entity.get_local_player() then
        return
    end
    local target_id = client.userid_to_entindex(e.userid)
    local enemy_health = entity.get_prop(target_id, "m_iHealth")
    local rem_health = enemy_health - e.dmg_health
    if rem_health <= 0 then
        rem_health = 0
    end
    hit_info.last_damage = rem_health
end
local function aim_fire(e)
    local hitgroup_names = { "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }
    local group = hitgroup_names[e.hitgroup + 1] or "?"
    local name = entity.get_player_name(e.target)
    notify:paint(3, "hit "..name.." hb: ( "..group.." ) dmg: ( "..e.damage.." ) hc: ( "..e.hit_chance.." ) rh: ( "..hit_info.last_damage.." )",e.target,false)
end

client.set_event_callback("aim_miss", aim_miss)
client.set_event_callback("aim_hit", aim_fire)
client.set_event_callback("player_hurt", player_hurt)
client.set_event_callback("paint", function()

    local active_alpha = contains(ui.get(extend_anim),"Log alpha")
    local death_line = contains(ui.get(extend_anim),"Death line")
    local active_arrow = contains(ui.get(extend_anim),"Hit arrow")
    local active_arrow_style = contains(ui.get(extend_anim),"Custom arrow style")

    ui.set_visible(death_line_label, death_line)
    ui.set_visible(death_line_color, death_line)

    ui.set_visible(arrow_hit_color, active_arrow)
    ui.set_visible(arrow_miss_color, active_arrow)
    ui.set_visible(arrow_hit_label, active_arrow)
    ui.set_visible(arrow_miss_label, active_arrow)

    ui.set_visible(arrow_hit_style, active_arrow_style)
    ui.set_visible(arrow_miss_style, active_arrow_style)

end)