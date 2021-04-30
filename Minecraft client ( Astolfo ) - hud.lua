local print = client.print

function draw_container(x, y, w, h)
    local c = {10, 60, 40, 40, 40, 60, 20}
    for i = 0,6,1 do
        render.rect(x+i, y+i, w-i, h-i,c[i+1], c[i+1], c[i+1], 255)
    end
end

local x = 0
local y = 0
local aura_id = 0
local lastTarget = 0

local on_paint = {
    on_render_screen = function(e)
        world.entities()
        local active_player_hud = module_manager.option("9910 HUD", "Local player hud")
        local aura_hud = module_manager.option("9910 HUD", "Killaura hud")

        local me = player.id()
        local aura_id = player.kill_aura_target()
        local me_yaw,me_pitch = player.angles()

        if aura_hud and aura_id ~= nil then
            
            local aura_yaw,aura_pitch = world.angles(aura_id)
            local arra_name = world.name(aura_id)
            local max_health = world.max_health(aura_id)
            local health = world.health(aura_id)
            local sprint = world.sprinting(aura_id)
            local sneak = world.is_sneaking(aura_id)
            local rideing = world.riding(aura_id)
            local state = ""
            if sprint then
                state = "sprinting"
            elseif sneak then
                state = "Sneaking"
            elseif rideing then
                state = "Riding"
            else
                state = "None"
            end
            local r = module_manager.option("9910 HUD", "Killaura hud - R")
            local g = module_manager.option("9910 HUD", "Killaura hud - G")
            local b = module_manager.option("9910 HUD", "Killaura hud - B")

            local world_x,world_y,world_z = world.position(aura_id)
            local xyz_sring = "XYZ: "..world_x.." "..world_y.." "..world_z
            draw_container(x+405,y+350,x+555,y+400)
            render.string_shadow("["..arra_name.."] - "..aura_id.." - "..state,x+440,y+360,255,255,255,255)
            render.string_shadow(xyz_sring,x+425, y+400,255,255,255,255)
            render.rect(x+440, y+375,x+530, y+390,0,0,0,60)
            render.rect(x+440, y+375,x+440+( health/max_health * 95 ), y+390,r,g,b,177)
            render.player(x+425, y+393, 18, 5,aura_pitch,aura_id)
        end
        
        if active_player_hud then
            render.player(x+360, y+540, 30, 0, me_pitch, me)
        end

        --[[ draw_container(x,y,x+150,y+50) ]]
    end,
    on_render_world = function(renderworld)
		aura_id = player.kill_aura_target()
        --[[ print(aura_id) ]]
		if aura_id ~= nil then
			if aura_id ~= lastTarget then
				lastTarget = aura_id
			end
		end
	end,
}

module_manager.register("9910 HUD", on_paint)
module_manager.register_boolean("9910 HUD", "Local player hud", false)
module_manager.register_number("9910 HUD", "Local player hud - R", 0, 255, 105)
module_manager.register_number("9910 HUD", "Local player hud - G", 0, 255, 64)
module_manager.register_number("9910 HUD", "Local player hud - B", 0, 255, 147)
module_manager.register_boolean("9910 HUD", "Killaura hud", false)
module_manager.register_number("9910 HUD", "Killaura hud - R", 0, 255, 105)
module_manager.register_number("9910 HUD", "Killaura hud - G", 0, 255, 64)
module_manager.register_number("9910 HUD", "Killaura hud - B", 0, 255, 147)