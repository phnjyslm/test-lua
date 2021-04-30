local client_userid_to_entindex, entity_get_local_player, entity_hitbox_position, globals_curtime, globals_tickcount, math_sqrt, renderer_line, renderer_world_to_screen, pairs, ui_get, ui_new_checkbox, ui_new_color_picker, ui_new_slider, ui_set_callback, ui_set_visible = client.userid_to_entindex, entity.get_local_player, entity.hitbox_position, globals.curtime, globals.tickcount, math.sqrt, renderer.line, renderer.world_to_screen, pairs, ui.get, ui.new_checkbox, ui.new_color_picker, ui.new_slider, ui.set_callback, ui.set_visible

local success, surface = pcall(require, 'gamesense/surface')

if not success then
    error('\n\n - Surface library is required \n - https://gamesense.pub/forums/viewtopic.php?id=18793\n')
end

local shot_data = {}
local segoe = surface.create_font('Verdana', 20, 500, { 0x010 })
local hit_marker = ui_new_checkbox("VISUALS", "Player ESP", "Hit marker 3D")
local images = require 'gamesense/images'
local svg = '<svg t="1614704799063" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="8191" width="200" height="200"><path d="M288.105 122.229C174.047 122.21 64.691 231.687 64.691 388.095c0 176.07 156.747 241.891 261.855 312.283 101.962 68.266 174.057 161.602 185.453 201.393 9.743-38.936 91.03-135.019 185.448-203.373 103.196-74.727 261.861-136.19 261.861-312.262 0-152.117-109.34-260.294-222.908-260.294-86.792 0-167.781 15.754-224.419 128.441-65.593-111.977-138.495-132.042-223.876-132.054" fill="#ff0000" p-id="8192"></path></svg>'
local img = images.load_svg(svg)

local function draw_heart(x, y)
	--outline
	--left
	renderer.rectangle(x + 2, y + 14, 2, 2, 0, 0, 0, 255)
	renderer.rectangle(x, y + 12, 2, 2, 0, 0, 0, 255)
	renderer.rectangle(x - 2, y + 10, 2, 2, 0, 0, 0, 255)
	renderer.rectangle(x - 4, y + 4, 2, 6, 0, 0, 0, 255)
	renderer.rectangle(x - 2, y + 2, 2, 2, 0, 0, 0, 255)
	renderer.rectangle(x, y, 2, 2, 0, 0, 0, 255)
	renderer.rectangle(x + 2, y, 2, 2, 0, 0, 0, 255)
	--center-top
	renderer.rectangle(x + 4, y + 2, 2, 2, 0, 0, 0, 255)
	--right
	renderer.rectangle(x + 6, y, 2, 2, 0, 0, 0, 255)
	renderer.rectangle(x + 8, y, 2, 2, 0, 0, 0, 255)
	renderer.rectangle(x + 10, y + 2, 2, 2, 0, 0, 0, 255)
	renderer.rectangle(x + 12, y + 4, 2, 6, 0, 0, 0, 255)
	renderer.rectangle(x + 10, y + 10, 2, 2, 0, 0, 0, 255)
	renderer.rectangle(x + 8, y + 12, 2, 2, 0, 0, 0, 255)
	renderer.rectangle(x + 6, y + 14, 2, 2, 0, 0, 0, 255)
	--center-bottom
	renderer.rectangle(x + 4, y + 16, 2, 2, 0, 0, 0, 255)

	--red-fill
	renderer.rectangle(x - 2, y + 4, 2, 6, 254, 19, 19, 255)
	renderer.rectangle(x, y + 2, 4, 2, 254, 19, 19, 255)
	renderer.rectangle(x, y + 6, 4, 6, 254, 19, 19, 255)
	renderer.rectangle(x + 2, y + 4, 2, 2, 254, 19, 19, 255)
	renderer.rectangle(x + 2, y + 12, 2, 2, 254, 19, 19, 255)
	renderer.rectangle(x + 4, y + 4, 2, 12, 254, 19, 19, 255)
	renderer.rectangle(x + 6, y + 2, 4, 10, 254, 19, 19, 255)
	renderer.rectangle(x + 6, y + 12, 2, 2, 254, 19, 19, 255)
	renderer.rectangle(x + 10, y + 4, 2, 6, 254, 19, 19, 255)

	--highlight
	renderer.rectangle(x, y + 4, 2, 2, 254, 199, 199, 255)
end
local function paint()
    if not ui_get(hit_marker) then
        return
    end

    local size = 3.5
    local size2 = 2.5

    for tick, data in pairs(shot_data) do

        if data.draw then
            
            if globals_curtime() >= data.time then
                data.alpha = data.alpha - 2    
            end
            local up = 0
            if globals_curtime() >= data.up_time then
                data.up_up = data.up_up - 2
            end

            if data.alpha <= 0 then
                data.alpha = 0
                data.draw = false
            end

            local sx, sy = renderer_world_to_screen(data.x, data.y, data.z)
            if sx ~= nil then
                local color = { 255, 255, 255 }

                if data.hs then
                    color = { 255, 0, 0 }
                end

                local damage_text = data.damage .. ''
                local w, h = surface.get_text_size(segoe, damage_text)
                
                local up = (data.up_up - 255)/255 * 50
                surface.draw_text(sx - w/2, sy - size*2 - h*1.1+up, color[1], color[2], color[3], data.alpha, segoe, damage_text)
                --[[ img:draw(sx - w/2-20, sy - size*2 - h*1.1+up,10,10,255,255,255,255,true,"f") ]]
                draw_heart(sx - w/2-20, sy - size*2 - h*1.1+up)
                renderer_line(sx + size, sy + size, sx + (size * size2), sy + (size * size2), 0, 0, 0, data.alpha)
                renderer_line(sx + size, sy + size, sx + (size * size2), sy + (size * size2), 255, 255, 255, math.max(0, data.alpha-35))

                renderer_line(sx - size, sy + size, sx - (size * size2), sy + (size * size2), 0, 0, 0, data.alpha)
                renderer_line(sx - size, sy + size, sx - (size * size2), sy + (size * size2), 255, 255, 255, math.max(0, data.alpha-35))

                renderer_line(sx + size, sy - size, sx + (size * size2), sy - (size * size2), 0, 0, 0, data.alpha)
                renderer_line(sx + size, sy - size, sx + (size * size2), sy - (size * size2), 255, 255, 255, math.max(0, data.alpha-35))

                renderer_line(sx - size, sy - size, sx - (size * size2), sy - (size * size2), 0, 0, 0, data.alpha)
                renderer_line(sx - size, sy - size, sx - (size * size2), sy - (size * size2), 255, 255, 255, math.max(0, data.alpha-35))
            end
        end
    end

end

local function player_hurt(e)
    if not ui_get(hit_marker) then
        return
    end

    local victim_entindex = client_userid_to_entindex(e.userid)
    local attacker_entindex = client_userid_to_entindex(e.attacker)

    if attacker_entindex ~= entity_get_local_player() then
        return
    end

    local tick = globals_tickcount()
    local data = shot_data[tick]

    if shot_data[tick] == nil or data.impacts == nil then
        return
    end

    local hitgroups = { 
        [1] = {0, 1}, 
        [2] = {4, 5, 6}, 
        [3] = {2, 3}, 
        [4] = {13, 15, 16}, 
        [5] = {14, 17, 18}, 
        [6] = {7, 9, 11}, 
        [7] = {8, 10, 12}
    }

    local impacts = data.impacts
    local hitboxes = hitgroups[e.hitgroup]
    
    local hit = nil
    local closest = math.huge

    for i=1, #impacts do
        local impact = impacts[i]

        if hitboxes ~= nil then
            for j=1, #hitboxes do
                local x, y, z = entity_hitbox_position(victim_entindex, hitboxes[j])
                local distance = math_sqrt((impact.x - x)^2 + (impact.y - y)^2 + (impact.z - z)^2)

                if distance < closest then
                    hit = impact
                    closest = distance
                end
            end
        end
    end

    if hit == nil then
        return
    end

    shot_data[tick] = {
        x = hit.x,
        y = hit.y,
        z = hit.z,
        time = globals_curtime() + 1 - 0.25,
        alpha = 255,
        damage = e.dmg_health,
        hs = e.hitgroup == 0 or e.hitgroup == 1,
        draw = true,
        up_time = globals_curtime(),
        up_up = 255,
    }
end

local function bullet_impact(e)
    if not ui_get(hit_marker) then
        return
    end

    if client_userid_to_entindex(e.userid) ~= entity_get_local_player() then
        return
    end

    local tick = globals_tickcount()

    if shot_data[tick] == nil then
        shot_data[tick] = {
            impacts = { }
        }
    end

    local impacts = shot_data[tick].impacts

    if impacts == nil then
        impacts = { }
    end

    impacts[#impacts + 1] = {
        x = e.x,
        y = e.y,
        z = e.z
    }
end

local function round_start()
    if not ui_get(hit_marker) then
        return
    end

    shot_data = { }
end

client.set_event_callback("paint", paint)
client.set_event_callback("player_hurt", player_hurt)
client.set_event_callback("round_start", round_start)
client.set_event_callback("bullet_impact", bullet_impact)