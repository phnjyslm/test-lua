client.exec("clear")
client.delay_call(0.1,client.color_log,255, 255, 255, "|--------------------------------------------------------|")
client.delay_call(0.2,client.color_log,222, 150, 255, "             Welcome use 9910 Anti-aim lua")
client.delay_call(0.3,client.color_log,255, 255, 255, "|--------------------------------------------------------|")

-- lua by coldegg 
local enable_anti           = ui.reference("AA","Anti-aimbot angles","Enabled")
local pitch                 = ui.reference("AA","Anti-aimbot angles","Pitch")
local yawbase               = ui.reference("AA","Anti-aimbot angles","Yaw base")
local yaw       ,yaw_sli    = ui.reference("AA","Anti-aimbot angles","Yaw")
local jitter    ,jitter_sli = ui.reference("AA","Anti-aimbot angles","Yaw jitter")
local body      ,body_sli   = ui.reference("AA","Anti-aimbot angles","Body yaw")
local free_body             = ui.reference("AA","Anti-aimbot angles","Freestanding body yaw")
local lby                   = ui.reference("AA","Anti-aimbot angles","Lower body yaw target")
local lby_limit             = ui.reference("AA","Anti-aimbot angles","Fake yaw limit")
local edge                  = ui.reference("AA","Anti-aimbot angles","Edge yaw")
local freestand ,freestand_key       = ui.reference("AA","Anti-aimbot angles","Freestanding")

local slow, slow_key    = ui.reference("AA", "Other", "Slow motion")
local dt,dt_key = ui.reference("Rage","Other","Double tap")
local fd = ui.reference("Rage","Other","Duck peek assist")
local fd_key = ui.reference("Misc","Movement","Infinite duck") 
local os,os_key = ui.reference("AA","Other","On shot anti-aim")
local pk,pk_key = ui.reference("AA","Other","Fake peek")

local legit = ui.new_checkbox("AA", "Anti-aimbot angles", "Enable legit")
local manual_right_dir = ui.new_hotkey("AA","Anti-aimbot angles","Right direction")
local manual_left_dir = ui.new_hotkey("AA","Anti-aimbot angles","Left direction") 
local manual_backward_dir = ui.new_hotkey("AA","Anti-aimbot angles","Backward direction")
local manual_state = ui.new_slider("AA","Anti-aimbot angles","\n",0,3,0)
ui.set_visible(manual_state,false)
local bind_system = {left = false,right = false,back = false,}
function bind_system:update()ui.set(manual_left_dir, "On hotkey");ui.set(manual_right_dir, "On hotkey");ui.set(manual_backward_dir, "On hotkey");local m_state = ui.get(manual_state);local left_state, right_state, backward_state = ui.get(manual_left_dir),ui.get(manual_right_dir),ui.get(manual_backward_dir);if  left_state == self.left and right_state == self.right and backward_state == self.back then return end;self.left, self.right, self.back = left_state,right_state,backward_state;if (left_state and m_state == 1) or (right_state and m_state == 2) or (backward_state and m_state == 3) then ui.set(manual_state, 0) return end;if left_state and m_state ~= 1 then ui.set(manual_state, 1)end;if right_state and m_state ~= 2 then ui.set(manual_state, 2)end;if backward_state and m_state ~= 3 then ui.set(manual_state, 3)end;end


local indicator = {}
local function set_anti(pitch_,base,yaw_,yaw_limit,jitter_,jitter_limit,body_,body_limit,freebody,lby_,lby_sli,edge_,free_stand,free_stand_key)
    ui.set(pitch,pitch_)
    ui.set(yawbase,base)
    ui.set(yaw,yaw_)
    ui.set(yaw_sli,yaw_limit)
    ui.set(jitter,jitter_)
    ui.set(jitter_sli,jitter_limit)
    ui.set(body,body_)
    ui.set(body_sli,body_limit)
    ui.set(free_body,freebody)
    ui.set(lby,lby_)
    ui.set(lby_limit,lby_sli)
    ui.set(edge,edge_)
    ui.set(freestand,free_stand)
    ui.set(freestand_key,free_stand_key)
end
local function g_set_commnad(e)
    --a 0x41
    --d 0x44
    --s 0x53
    --w 0x57
    if ui.get(legit) then 

        set_anti("Off","Local view","180",180,"Off",0,"Static",90,true,"Opposite",60,true,"-","On hotkey")

        return
    end
    local a = client.key_state(0x41)
    local d = client.key_state(0x44)
    local s = client.key_state(0x53)
    local w = client.key_state(0x57)
    
    local forward = w
    local backward = s
    local on_left = a
    local on_right = d

    local slow_s = ui.get(slow) and ui.get(slow_key) and backward
    local slow_w = ui.get(slow) and ui.get(slow_key) and forward
    local slow_left = on_left and ui.get(slow) and ui.get(slow_key)
    local slow_right = on_right and ui.get(slow) and ui.get(slow_key)
    
    local dt_active = ui.get(dt) and ui.get(dt_key)
    local fd_active = ui.get(fd) and ui.get(fd_key)
    local os_active = ui.get(os) and ui.get(os_key)
    local pk_active = ui.get(pk) and ui.get(pk_key)

    -- on anti set --
    ui.set(enable_anti,true)

    if w or s then
        set_anti("Default","At targets","180",0,"Off",0,"Jitter",0,true,"Opposite",58,true,"-","Always on")
    end
    if slow_w or slow_s then
        set_anti("Default","Local view","180",0,"Off",0,"Jitter",95,false,"Opposite",58,false,"","On hotkey")
    end
    if a then
        set_anti("Default","At targets","180",10,"Off",0,"Static",-90,true,"Opposite",58,true,"-","Always on")
    end
    if slow_left then
        set_anti("Default","Local view","180",-10,"Off",0,"Jitter",95,true,"Opposite",58,false,"","On hotkey")
    end
    if d then
        set_anti("Default","At targets","180",-10,"Off",0,"Static",90,true,"Opposite",58,true,"-","Always on")
    end
    if slow_right then
        set_anti("Default","Local view","180",10,"Off",0,"Jitter",95,false,"Opposite",58,false,"","On hotkey")
    end

    if bit.band(entity.get_prop(entity.get_local_player(), "m_fFlags"), 1) ~= 1 or (e and e.in_jump == 1) then
        set_anti("Default","At targets","180",0,"Off",0,"Static",90,true,"Opposite",58,true,"-","Always on")
    end
    if client.key_state(0x45) then
		local weaponn = entity.get_player_weapon()
		if weaponn ~= nil and entity.get_classname(weaponn) == "CC4" then
			if e.in_attack == 1 then
				e.in_attack = 0
				e.in_use = 1
			end
		else
			if e.chokedcommands == 0 then
				e.in_use = 0
			end
        end
    end
    if dt_active or fd_active or os_active or pk_active then
        ui.set(lby,"Eye yaw")
    end
    if ui.get(manual_state) == 1 then
        set_anti("Default","Local view","180",-90,"Off",0,"Opposite",90,true,"Opposite",58,false,"","On hotkey")
    elseif ui.get(manual_state) == 2 then
        set_anti("Default","Local view","180",90,"Off",0,"Opposite",90,true,"Opposite",58,false,"","On hotkey")
    elseif ui.get(manual_state) == 3 then  
        set_anti("Default","Local view","180",0,"Off",0,"Opposite",90,true,"Opposite",58,false,"","On hotkey")
    end

end

local function g_on_paint()
    if ui.get(legit) then 
        return
    end
    bind_system:update()
    local me = entity.get_local_player()
    if me == nil then return end
    local window_x , window_y  = client.screen_size()
    local x , y = window_x / 2 , window_y / 2
    --[[ ▶◀ ▼]]
    if ui.get(manual_state) ~= 0 then 
        renderer.text(x,y + 10,255,255,255,255,"cb",0,"Manual")
    end
    if ui.get(manual_state) == 1 then
        renderer.text(x - 70,y - 5,255,255,255,255,"c+",0,"⯇")
    elseif ui.get(manual_state) == 2 then
        renderer.text(x + 70,y - 5,255,255,255,255,"c+",0,"⯈")
    elseif ui.get(manual_state) == 3 then
        renderer.text(x ,y + 80,255,255,255,255,"c+",0,"▼")
    end
end

client.set_event_callback("setup_command",g_set_commnad)
client.set_event_callback("paint", g_on_paint)