local success, surface = pcall(require, 'gamesense/surface')

if not success then
    error('\n\n - Surface library is required \n - https://gamesense.pub/forums/viewtopic.php?id=18793\n')
end

local font = surface.create_font('small', 14, 400, { 0x200 --[[ Outline ]] })

local fakelag                           = ui.reference      ("AA", "Fake lag", "Limit")
local variance                          = ui.reference      ("AA", "Fake lag", "Variance")
local cmdticks                          = ui.reference      ("MISC", "Settings", "sv_maxusrcmdprocessticks")

local dt, dt_key                        = ui.reference      ("RAGE", "Other", "Double tap")
local fd                                = ui.reference      ("RAGE", "Other", "Duck peek assist")
local os, os_key                        = ui.reference("AA","Other","On shot anti-aim")

local max_tick = ui.reference('misc', 'settings', 'sv_maxusrcmdprocessticks')

local active_fix = ui.new_checkbox("AA","Fake lag","Fix shot lag")

local fix_lag = false
local fixing_lag = 0
local weapon_ready = function(me, wpn)
    if wpn == nil then
      return false
    end
  
    local tickbase = entity.get_prop(me, 'm_nTickBase')
    local curtime = globals.tickinterval() * tickbase
  
    if curtime < entity.get_prop(me, 'm_flNextAttack') then
      return false
    end
  
    if curtime < entity.get_prop(wpn, 'm_flNextPrimaryAttack') then
      return false
    end
  
    return true
end
local cmove = {

    weapon_ready = false,
    has_been_fired = false,
    last_command_is_ran = false,
    shot_being_limited = false,

    last_weapon_idx = -1,

}
local old_tick,fl1,fl2,fl3 = 0,0,0,0
local shot_time = 0
local fix_safe = false
local fix_safe_time = 0
local function main(cmd)
	if cmd.chokedcommands < old_tick then --sent
		fl1 = fl2
		fl2 = fl3
		fl3 = old_tick
	end
	
	old_tick = cmd.chokedcommands
    if not ui.get(active_fix) then 
        return
    end
    if ui.get(fd) then 
        return 
    end
    if ui.get(dt) and ui.get(dt_key) then 
        return 
    end
    if ui.get(os) and ui.get(os_key) then 
        return 
    end
    local me = entity.get_local_player()
    local wpn = entity.get_player_weapon(me)
    local weapon_id = bit.band(entity.get_prop(wpn, "m_iItemDefinitionIndex"), 0xFFFF)


    -- animations
    local _bSendPacket = cmd.allow_send_packet
    local _fChokedCmds = cmd.chokedcommands


    local weapon_ready = weapon_ready(me, wpn)
    local weapon_index = bit.band(entity.get_prop(wpn, 'm_iItemDefinitionIndex') or 0, 0xFFFF)
    
    if not weapon_ready and weapon_ready ~= cmove.weapon_ready and cmove.last_weapon_idx == weapon_index then
        cmove.has_been_fired = true
        fixing_lag = fl1
        fix_lag = true
        shot_time = globals.realtime() + 0.3
    else
        if shot_time < globals.realtime() then
            fix_lag = false
        end
    end

    if weapon_id == 43 or weapon_id == 44 or weapon_id == 45 or weapon_id == 48 or weapon_id == 47 or weapon_id == 515 or weapon_id ==31 or not entity.is_alive(entity.get_local_player()) then
        fix_lag = false
        fix_safe = false
        cmove.has_been_fired = false
        return
    end

    _bSendPacket = false
    
    if cmove.has_been_fired then

        _bSendPacket = true
        
        if _fChokedCmds < 14 then
--[[             stored_yaw = cmd.yaw - 180
            angle = cmd.yaw - stored_yaw 
            cmd.yaw = cmd.yaw + angle
            cmd.pitch = 90  ]]
            cmd.allow_send_packet = true
            fix_safe = true
            fix_safe_time = globals.realtime() + 0.3
        end

        if _fChokedCmds == 0 and cmove.last_command_is_ran then
            local original_hbf = cmove.has_been_fired
            local original_hbl = cmove.shot_being_limited

            cmove.has_been_fired = false

            -- recreating `alternative` fake-lag on-shot
            if not cmove.shot_being_limited then
                cmove.shot_being_limited = true
                cmove.has_been_fired = 1
                
            end

            if original_hbf == 1 or original_hbl then
                cmove.shot_being_limited = false
            end
        end
    else
        if fix_safe_time < globals.realtime() then
            fix_safe = false
        end
    end
    
     
    cmove.weapon_ready = weapon_ready
    cmove.last_weapon_idx = weapon_index
    cmove.last_command_is_ran = false
    cmd.allow_send_packet = _bSendPacket

end
local alpha = 0
client.set_event_callback("setup_command",main)
client.set_event_callback("paint",function()
    if not ui.get(active_fix) then 
        return
    end
    local frame = 1000 * globals.frametime()
    if fix_lag then
        alpha = alpha + frame > 255 and 255 or alpha + frame
        
    else
        alpha = alpha - frame < 0 and 0 or alpha - frame
    end

    local w,h = client.screen_size()
    local text = "lag fix: "
    local text_w,text_h = surface.get_text_size(font, text)
    surface.draw_text(w/2 - text_w/2, h-50, 255, 255, 255, 255, font, text)

    local fix_angle = fix_lag and fix_safe and "safe" or "wait"
    surface.draw_text(w/2 - text_w/2 + text_w, h-50, 
    fix_angle == "safe" and 152 or 255, 
    fix_angle == "safe" and 255 or 57,
    fix_angle == "safe" and 57  or 57, 
    255, 
    font, fix_angle.."")
    local fix_angle_w,fix_angle_h = surface.get_text_size(font,fix_angle)

    renderer.gradient(w/2 - text_w/2,h-50+text_h, fl1/(ui.get(max_tick)-2) * (fix_angle_w+text_w) ,7,89, 119, 239,0,89, 119, 239, alpha,true)

    
end)

client.set_event_callback("run_command", function()
    cmove.last_command_is_ran = true
end)
