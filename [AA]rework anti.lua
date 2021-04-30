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
local slowmo, slowmo_key    = ui.reference("AA", "Other", "Slow motion")
local ref_mindmg            = ui.reference("RAGE", 'Aimbot' , "Minimum Damage")

local dt,dt_key = ui.reference("Rage","Other","Double tap")
local fd = ui.reference("Rage","Other","Duck peek assist")
local fd_key = ui.reference("Misc","Movement","Infinite duck") 
local os,os_key = ui.reference("AA","Other","On shot anti-aim")
local peek,peek_key = ui.reference("AA","Other","Fake peek")
-- ffi
local ffi = require "ffi"
local function vmt_entry(instance, index, type)
    return ffi.cast(type, (ffi.cast("void***", instance)[0])[index])
end

local function vmt_bind(module, interface, index, typestring)
    local instance = client.create_interface(module, interface) or error("invalid interface")
    local fnptr = vmt_entry(instance, index, ffi.typeof(typestring)) or error("invalid vtable")
    return function(...)
        return fnptr(instance, ...)
    end
end

local native_GetClipboardTextCount = vmt_bind("vgui2.dll", "VGUI_System010", 7, "int(__thiscall*)(void*)")
local native_SetClipboardText = vmt_bind("vgui2.dll", "VGUI_System010", 9, "void(__thiscall*)(void*, const char*, int)")
local native_GetClipboardText = vmt_bind("vgui2.dll", "VGUI_System010", 11, "int(__thiscall*)(void*, int, const char*, int)")

function get_clipboard_text()
    local size = native_GetClipboardTextCount()
    if size > 0 then
        local char = ffi.new("char[?]", size)
        local bytesize = size * ffi.sizeof("char[?]", size)
        native_GetClipboardText(0, char, bytesize)
        return ffi.string(char, size-1)
    end
end

function set_clipboard_text(text)
    native_SetClipboardText(text, text:len())
end

-- database
local write_list = {
    ["default"] = 0,
    ["custom"] = 0,
}

local read_datebase = database.read("cold_anti_datebase")
if write_list == nil then
    database.write("cold_anti_datebase",write_list)
end
-- ui
local active = ui.new_checkbox("AA","Anti-aimbot angles","KaNo Anti")
local angle_state = ui.new_combobox("AA","Anti-aimbot angles","Switch body yaw","Freestanding real","Freestanding fake","Key")
local switch_key = ui.new_hotkey("AA","Anti-aimbot angles","Switch body yaw")
local manual_right_dir = ui.new_hotkey("AA","Anti-aimbot angles","Right direction")
local manual_left_dir = ui.new_hotkey("AA","Anti-aimbot angles","Left direction") 
local manual_backward_dir = ui.new_hotkey("AA","Anti-aimbot angles","Backward direction")
local manual_state = ui.new_slider("AA","Anti-aimbot angles","\n",0,3,0)
local force_anti = ui.new_hotkey("AA","Anti-aimbot angles","Force Anti-aim")
local e_legit_peek = ui.new_checkbox("AA","Anti-aimbot angles","E peek")
local config_names = { "Global", "Stand", "Slow motion" , "Manual right" , "Manual left" , "Manual back" , "Force anti" }
local active_anti = ui.new_combobox("AA","Anti-aimbot angles", "Anti state", config_names)
ui.set_visible(manual_state,false)
local jitter_delay = 0
local rage_fire_delay = true
local break_indicator = false
local last_anti = 0
local rage = {}
local active_idx = 1
local name_to_num = { 
    ["Global"] = 1, 
    ["stand"] = 2, 
    ["Slow motion"] = 3, 
    ["Manual right"] = 4,
    ["Manual left"] = 5,
    ["Manual back"] = 6,
    ["Force anti"] = 7, 
}
local anti_idx = { 
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7
}
for i=1, #config_names do
    rage[i] = {
        c_enabled = ui.new_checkbox("AA","Anti-aimbot angles", "Enable " .. config_names[i] .. " config"),
        c_anti_state = ui.new_combobox("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Anti state", {"Gamesense","Rework anti"}),
        -- gamesense anti
        c_pitch = ui.new_combobox("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Pitch", {"Off","Down","Up"}),
        c_yawbase = ui.new_combobox("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Yaw base", {"Local view","At targets"}),
        c_yaw = ui.new_combobox("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Yaw", {"Off","180"}),
        c_yaw_sli = ui.new_slider("AA","Anti-aimbot angles", "\n[" .. config_names[i] .. "] yaw sli", -180, 180, 0, true, "°", 1),
        c_jitter = ui.new_combobox("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Yaw jitter", {"Off","Offset","Center","Random"}),
        c_jitter_sli = ui.new_slider("AA","Anti-aimbot angles", "\n[" .. config_names[i] .. "] jitter sli", -180, 180, 0, true, "°", 1),
        c_body = ui.new_combobox("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Body yaw", {"Off","Opposite","Jitter","Static"}),
        c_body_sli = ui.new_slider("AA","Anti-aimbot angles", "\n[" .. config_names[i] .. "] body sli", -180, 180, 0, true, "°", 1),
        c_lby = ui.new_combobox("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Lower body yaw target", {"Off","Sway","Opposite","Eye yaw"}),
        -- Rework anti
        c_anti_yaw = ui.new_combobox("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Rework yaw", {"Off","Normal","Spin","Jitter"}),
        -- normal yaw
        c_anti_yaw_normal_slider = ui.new_slider("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Rework normal yaw", -180, 180, 0, true, "°", 1),
        -- spin yaw
        c_anti_yaw_spin_slider_default = ui.new_slider("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Rework spin yaw", -180, 180, 0, true, "°", 1),
        c_anti_yaw_spin_slider_var = ui.new_slider("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Rework spin var", -5, 5, 0, true, "t", 1),
        c_anti_yaw_spin_slider_max = ui.new_slider("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Rework spin max", -180, 180, 0, true, "°", 1),
        -- jitter yaw
        c_anti_yaw_jitter_slider_default = ui.new_slider("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Rework jitter yaw", -180, 180, 0, true, "°", 1),
        c_anti_yaw_jitter_slider_var = ui.new_slider("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Rework jitter var", -180, 180, 0, true, "°", 1),
        -- body yaw
        c_anti_body = ui.new_combobox("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Rework body yaw", {"Off","Static","Jitter","Opposite"}),
        c_anti_body_slider_right = ui.new_slider("AA","Anti-aimbot angles", "[" .. config_names[i] .. "]Rework body R", -180, 180, 0, true, "°", 1),
        c_anti_body_slider_left = ui.new_slider("AA","Anti-aimbot angles", "[" .. config_names[i] .. "]Rework body L", -180, 180, 0, true, "°", 1),
        -- lby
        c_anti_lby = ui.new_combobox("AA","Anti-aimbot angles", "[" .. config_names[i] .. "] Rework lby", {"Eye yaw","Opposite","Sway","Adaptive"}),
    }
end

-- by Crim_sync(Salvatore)
local sandvich_aa = (function()local a=90;local b=function(c,d,e,f)local g=math.atan((d-f)/(c-e))return g*180/math.pi end;local h=function(c,d)local i,j,k,l=nil;j=math.sin(math.rad(d))l=math.cos(math.rad(d))i=math.sin(math.rad(c))k=math.cos(math.rad(c))return k*l,k*j,-i end;local m=function(n,o,p,q,r,s,t)local c,d,e=entity.get_prop(n,"m_vecOrigin")if c==nil then return-1 end;local u=function(v,w,x)local y=math.sqrt(v*v+w*w+x*x)if y==0 then return 0,0,0 end;local z=1/y;return v*z,w*z,x*z end;local A=function(B,C,D,E,F,G)return B*E+C*F+D*G end;local H,I,J=u(c-r,d-s,e-t)return A(H,I,J,o,p,q)end;local K=function(c,d)local L,M=math.rad(c),math.rad(d)local N,O,P,Q=math.sin(L),math.cos(L),math.sin(M),math.cos(M)return O*Q,O*P,-N end;local R=function(S,n,...)local T,U,V=entity.get_prop(S,"m_vecOrigin")local W,X=client.camera_angles()local Y,Z,_=entity.hitbox_position(S,0)local a0,a1,a2=entity.get_prop(n,"m_vecOrigin")local a3=nil;local a4=math.huge;if entity.is_alive(n)then local a5=b(T,U,a0,a1)for a6,a7 in pairs({...})do local a8,a9,aa=h(0,a5+a7)local ab=T+a8*55;local ac=U+a9*55;local ad=V+80;local ae,af=client.trace_bullet(n,a0,a1,a2+70,ab,ac,ad)local ag,ah=client.trace_bullet(n,a0,a1,a2+70,ab+12,ac,ad)local ai,aj=client.trace_bullet(n,a0,a1,a2+70,ab-12,ac,ad)if af<a4 then a4=af;if ah>af then a4=ah end;if aj>af then lowestdamage=aj end;if T-a0>0 then a3=a7 else a3=a7*-1 end elseif af==a4 then return 0 end end end;return a3 end;local ak=function()local S=entity.get_local_player()local al,am,an=entity.get_prop(S,"m_vecOrigin")if S==nil or al==nil then return end;local ao=entity.get_players(true)local ap,aq=client.camera_angles()local ar,as,at=K(ap,aq)local au=-1;local av=0;for aw=1,#ao do local ax=ao[aw]if entity.is_alive(ax)then local ay=m(ax,ar,as,at,al,am,an)if ay>au then au=ay;av=ax end end end;if av~=0 then local az=R(S,av,-90,90)if az~=0 then a=az end;if a<0 then return-60 elseif a>0 then return 60 end end end;return{process=ak}end)()
-- by crim_sync(Salvatore)
local bind_system = {left = false,right = false,back = false,}
function bind_system:update()ui.set(manual_left_dir, "On hotkey");ui.set(manual_right_dir, "On hotkey");ui.set(manual_backward_dir, "On hotkey");local m_state = ui.get(manual_state);local left_state, right_state, backward_state = ui.get(manual_left_dir),ui.get(manual_right_dir),ui.get(manual_backward_dir);if  left_state == self.left and right_state == self.right and backward_state == self.back then return end;self.left, self.right, self.back = left_state,right_state,backward_state;if (left_state and m_state == 1) or (right_state and m_state == 2) or (backward_state and m_state == 3) then ui.set(manual_state, 0) return end;if left_state and m_state ~= 1 then ui.set(manual_state, 1)end;if right_state and m_state ~= 2 then ui.set(manual_state, 2)end;if backward_state and m_state ~= 3 then ui.set(manual_state, 3)end;end
local function contains(table, val)
    if #table > 0 then
        for i=1, #table do
            if table[i] == val then
                return true
            end
        end
    end
    return false
end
local get_flags = function(cm)
    local state = "Default"
    local me = entity.get_local_player()

    local flags = entity.get_prop(me, "m_fFlags")
    local x, y, z = entity.get_prop(me, "m_vecVelocity")
    local velocity = math.floor(math.min(10000, math.sqrt(x^2 + y^2) + 0.5))

    if bit.band(flags, 1) ~= 1 or (cm and cm.in_jump == 1) then state = 1 else
        if ui.get(slowmo) and ui.get(slowmo_key) then 
            state = 3
        elseif velocity > 10 then
            state = 1
        else 
            state = 2
        end 
    end
    if ui.get(force_anti) then
        state = 7
    elseif ui.get(manual_state) == 2  then
        state = 4
    elseif ui.get(manual_state) == 1 then
        state = 5
    elseif ui.get(manual_state) == 3 then
        state = 6
    end
    return {
        velocity = velocity,
        state = state
    }
end

local num_round = function(x, n)
    n = math.pow(10, n or 0); x = x * n
    x = x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
    return x / n
end

local function handle_menu()
    local enabled = ui.get(active)
    ui.set_visible(active_anti, enabled)
    for i=1, #config_names do
        local show = ui.get(active_anti) == config_names[i] and enabled
        ui.set_visible(rage[i].c_enabled, show and i > 1)
        -- gamesense
        ui.set_visible(rage[i].c_pitch,show and ui.get(rage[i].c_anti_state) ==  "Gamesense")
        ui.set_visible(rage[i].c_yawbase,show)
        ui.set_visible(rage[i].c_yaw,show and ui.get(rage[i].c_anti_state) ==  "Gamesense")
        ui.set_visible(rage[i].c_yaw_sli,show and ui.get(rage[i].c_yaw) == "180" and ui.get(rage[i].c_anti_state) ==  "Gamesense")
        ui.set_visible(rage[i].c_jitter,show and ui.get(rage[i].c_yaw) ~= "Off" and ui.get(rage[i].c_anti_state) ==  "Gamesense")
        ui.set_visible(rage[i].c_jitter_sli,show and ui.get(rage[i].c_yaw) ~= "Off" and ui.get(rage[i].c_jitter) ~= "Off" and ui.get(rage[i].c_anti_state) ==  "Gamesense")
        ui.set_visible(rage[i].c_body,show and ui.get(rage[i].c_anti_state) ==  "Gamesense")
        ui.set_visible(rage[i].c_body_sli,show and ui.get(rage[i].c_body) ~= "Off" and ui.get(rage[i].c_body) ~= "Opposite" and ui.get(rage[i].c_anti_state) ==  "Gamesense")
        ui.set_visible(rage[i].c_lby,show and ui.get(rage[i].c_anti_state) ==  "Gamesense")
        -- rework
        ui.set_visible(rage[i].c_anti_state,show)
        ui.set_visible(rage[i].c_anti_yaw,show and ui.get(rage[i].c_anti_state) ==  "Rework anti")
        ui.set_visible(rage[i].c_anti_yaw_normal_slider,show and ui.get(rage[i].c_anti_yaw) == "Normal" and ui.get(rage[i].c_anti_state) ==  "Rework anti" )
        ui.set_visible(rage[i].c_anti_yaw_spin_slider_default,show and ui.get(rage[i].c_anti_yaw) == "Spin" and ui.get(rage[i].c_anti_state) ==  "Rework anti" )
        ui.set_visible(rage[i].c_anti_yaw_spin_slider_var,show and ui.get(rage[i].c_anti_yaw) == "Spin" and ui.get(rage[i].c_anti_state) ==  "Rework anti" )
        ui.set_visible(rage[i].c_anti_yaw_spin_slider_max,show and ui.get(rage[i].c_anti_yaw) == "Spin" and ui.get(rage[i].c_anti_state) ==  "Rework anti" )
        ui.set_visible(rage[i].c_anti_yaw_jitter_slider_default,show and ui.get(rage[i].c_anti_yaw) == "Jitter" and ui.get(rage[i].c_anti_state) ==  "Rework anti" )
        ui.set_visible(rage[i].c_anti_yaw_jitter_slider_var,show and ui.get(rage[i].c_anti_yaw) == "Jitter" and ui.get(rage[i].c_anti_state) ==  "Rework anti" )
        ui.set_visible(rage[i].c_anti_body,show and ui.get(rage[i].c_anti_state) ==  "Rework anti")
        ui.set_visible(rage[i].c_anti_body_slider_left,show and ui.get(rage[i].c_anti_body) ~= "Opposite" and ui.get(rage[i].c_anti_body) ~= "Off" and ui.get(rage[i].c_anti_state) ==  "Rework anti")
        ui.set_visible(rage[i].c_anti_body_slider_right,show and ui.get(rage[i].c_anti_body) ~= "Opposite" and ui.get(rage[i].c_anti_body) ~= "Off" and ui.get(rage[i].c_anti_state) ==  "Rework anti")
        ui.set_visible(rage[i].c_anti_lby,show and ui.get(rage[i].c_anti_state) ==  "Rework anti")
    end
    -- other
    ui.set_visible(switch_key,ui.get(angle_state) == "Key")
end
handle_menu()
local function default_config()
    
end

local function import_config()

end

local function export_config()

end

local load_default = ui.new_button("Lua","B","Load default config",default_config)
local import_config = ui.new_button("Lua","B","Import from clipcoard",import_config)
local export_config = ui.new_button("Lua","B","Export to clipcoard",export_config)
local function gamesense_anti(i,e)
    ui.set(pitch,ui.get(rage[i].c_pitch))
    ui.set(yawbase,ui.get(rage[i].c_yawbase))
    ui.set(yaw,ui.get(rage[i].c_yaw))
    ui.set(yaw_sli,ui.get(rage[i].c_yaw_sli))
    ui.set(jitter,ui.get(rage[i].c_jitter))
    ui.set(jitter_sli,ui.get(rage[i].c_jitter_sli))
    ui.set(body,ui.get(rage[i].c_body))
    ui.set(edge,false)
    ui.set(free_body,false)
    ui.set(freestand ,"-")
    ui.set(freestand_key,"On hotkey")
    ui.set(lby,ui.get(rage[i].c_lby))
    local free_angle = sandvich_aa:process() or 60
    
    if ui.get(angle_state) == "Freestanding real" then
        
        if free_angle == 60 then
            if ui.get(rage[i].c_body_sli) > 0 then
                ui.set(body_sli,ui.get(rage[i].c_body_sli))
            else
                ui.set(body_sli,-ui.get(rage[i].c_body_sli))
            end
        elseif free_angle == -60 then
            if ui.get(rage[i].c_body_sli) > 0 then
                ui.set(body_sli,-ui.get(rage[i].c_body_sli))
            else
                ui.set(body_sli,ui.get(rage[i].c_body_sli))
            end
        end
    elseif ui.get(angle_state) == "Freestanding fake" then
        if free_angle == -60 then
            if ui.get(rage[i].c_body_sli) > 0 then
                ui.set(body_sli,ui.get(rage[i].c_body_sli))
            else
                ui.set(body_sli,-ui.get(rage[i].c_body_sli))
            end
        elseif free_angle == 60 then
            if ui.get(rage[i].c_body_sli) > 0 then
                ui.set(body_sli,-ui.get(rage[i].c_body_sli))
            else
                ui.set(body_sli,ui.get(rage[i].c_body_sli))
            end
        end
    elseif ui.get(angle_state) == "Key" then
        ui.set(body_sli,ui.get(switch_key) and -ui.get(rage[i].c_body_sli) or ui.get(rage[i].c_body_sli))
    end
    
    ui.set(lby_limit,math.abs(ui.get(rage[i].c_body_sli)) > 58 and 58 or math.abs(ui.get(rage[i].c_body_sli)))
end
local function rework_anti(i,e)
    ui.set(edge,false)
    ui.set(freestand ,"-")
    ui.set(freestand_key,"On hotkey")
    ui.set(pitch,"Down")
    ui.set(yaw,"180")
    -- ui.set(yaw_sli,ui.get(rage[i].c_yaw_sli))
    ui.set(jitter,"Off")
    ui.set(free_body,false)
    ui.set(jitter_sli,0)
    
    ui.set(body,ui.get(rage[i].c_anti_body))
    local me = entity.get_local_player()
    local x, y, z = entity.get_prop(me, "m_vecVelocity")
    local velocity = math.floor(math.min(10000, math.sqrt(x^2 + y^2) + 0.5))
    local dt_active = ui.get(dt) and ui.get(dt_key)
    local fd_active = ui.get(fd) and ui.get(fd_key)
    local os_active = ui.get(os) and ui.get(os_key)
    local peek_active = ui.get(peek) and ui.get(peek_key)
    if ui.get(rage[i].c_anti_lby) == "Adaptive" then
        if dt_active or fd_active or os_active or peek_active then
            ui.set(lby,"Eye yaw")
        elseif velocity < 10 then
            ui.set(lby,"Sway")
        else
            ui.set(lby,"Opposite")
        end
    else
        ui.set(lby,ui.get(rage[i].c_anti_lby))
    end
    local spin_max = ui.get(rage[i].c_anti_yaw_spin_slider_max)
    local spin_default = ui.get(rage[i].c_anti_yaw_spin_slider_default)
    local spin_var = ui.get(rage[i].c_anti_yaw_spin_slider_var)
    local free_angle = sandvich_aa:process()
    if ui.get(rage[i].c_anti_yaw) == "Off" then
        ui.set(yaw,"Off")
    elseif ui.get(rage[i].c_anti_yaw) == "Normal" then
        ui.set(yaw_sli,ui.get(rage[i].c_anti_yaw_normal_slider))
    elseif ui.get(rage[i].c_anti_yaw) == "Spin" then
        if spin_max >= 0 then
            spin_var = math.abs(spin_var)
        else
            spin_var = - math.abs(spin_var)
        end
        if spin_default < spin_max and ui.get(yaw_sli) < spin_max then

            ui.set(yaw_sli,ui.get(yaw_sli) + spin_var > 180 and 180 or ui.get(yaw_sli) + spin_var)

        elseif spin_default > spin_max and ui.get(yaw_sli) > spin_max then
            ui.set(yaw_sli,ui.get(yaw_sli) + spin_var < -180 and -180 or ui.get(yaw_sli) + spin_var)
        else
            ui.set(yaw_sli,spin_default)
        end
    elseif ui.get(rage[i].c_anti_yaw) == "Jitter" then
        if globals.realtime() >= jitter_delay then
            client.delay_call(0.02,ui.set,yaw_sli,ui.get(rage[i].c_anti_yaw_jitter_slider_default))
            client.delay_call(0.04,ui.set,yaw_sli,ui.get(rage[i].c_anti_yaw_jitter_slider_var))
            jitter_delay = globals.realtime() + 0.04
        end
    end

    if ui.get(angle_state) == "Freestanding real" then
        if free_angle == 60 then
            ui.set(body_sli,ui.get(rage[i].c_anti_body_slider_right))
        elseif free_angle == -60 then
            ui.set(body_sli,ui.get(rage[i].c_anti_body_slider_left))
        end
    elseif ui.get(angle_state) == "Freestanding fake" then
        if free_angle == -60 then
            ui.set(body_sli,ui.get(rage[i].c_anti_body_slider_right))
        elseif free_angle == 60 then
            ui.set(body_sli,ui.get(rage[i].c_anti_body_slider_left))
        end
    elseif ui.get(angle_state) == "Key" then
        ui.set(body_sli,ui.get(switch_key) and ui.get(rage[i].c_anti_body_slider_left) or ui.get(rage[i].c_anti_body_slider_right))
    end
    
    ui.set(lby_limit,math.abs(ui.get(body_sli)) > 58 and 58 or math.abs(ui.get(body_sli)))
end
local function set_config(idx,cmd)
    local i = ui.get(rage[idx].c_enabled) and idx or 1
    ui.set(edge,false)
    ui.set(freestand,"")
    ui.set(freestand_key,"On hotkey")

    if client.key_state(0x45) and ui.get(e_legit_peek) then
		local weaponn = entity.get_player_weapon()
		if weaponn ~= nil and entity.get_classname(weaponn) == "CC4" then
			if cmd.in_attack == 1 then
				cmd.in_attack = 0
				cmd.in_use = 1
			end
		else
			if cmd.chokedcommands == 0 then
				cmd.in_use = 0
			end
        end
        ui.set(yawbase,"Local view")
        ui.set(free_body,true)
        ui.set(body_sli,60)
        ui.set(body,"Opposite")
        ui.set(lby,"Opposite")
        ui.set(lby_limit,60)
	else
        if ui.get(rage[i].c_anti_state) == "Gamesense" then
            gamesense_anti(i,cmd)
        elseif ui.get(rage[i].c_anti_state) == "Rework anti" then
            rework_anti(i,cmd)
        end
    end
    active_idx = i
end
local function run_handle(cmd)

    if not ui.get(active) then 
        return
    end
    bind_system:update()
    local flags = get_flags(cmd)
    local anti_id = flags.state
    local anti_text = config_names[anti_idx[anti_id]]

    if anti_text ~= nil then
        if last_anti ~= anti_id then
            ui.set(active_anti, ui.get(rage[anti_idx[anti_id]].c_enabled) and anti_text or "Global")
            last_anti = anti_id
        end
        set_config(anti_idx[anti_id],cmd)
    else
        if last_anti ~= anti_id then
            ui.set(active_anti, "Global")
            last_anti = anti_id
        end
        set_config(1,cmd)
    end
end
local function ui_visible()
    ui.set_visible(enable_anti,not ui.get(active))
    ui.set_visible(pitch,not ui.get(active))
    ui.set_visible(yawbase,not ui.get(active))
    ui.set_visible(yaw,not ui.get(active))
    ui.set_visible(yaw_sli,not ui.get(active))
    ui.set_visible(jitter,not ui.get(active))
    ui.set_visible(jitter_sli,not ui.get(active))
    ui.set_visible(body,not ui.get(active))
    ui.set_visible(body_sli,not ui.get(active))
    ui.set_visible(free_body,not ui.get(active))
    ui.set_visible(lby,not ui.get(active))
    ui.set_visible(lby_limit,not ui.get(active))
    ui.set_visible(edge,not ui.get(active))
    ui.set_visible(freestand,not ui.get(active))
    ui.set_visible(freestand_key,not ui.get(active))
end
local function paint_indicator()

    --[[ ▶◀ ▼]]
    ui_visible()
    if not ui.get(active) then return end
    
    local me = entity.get_local_player()
    local body_pos = entity.get_prop(me, "m_flPoseParameter", 11) or 0
    local body_yaw = math.max(-60, math.min(60, num_round(body_pos*120-60+0.5, 1)))
    
    local window_x , window_y  = client.screen_size()
    local x , y = window_x / 2 , window_y / 2
    local alpha = 1 + math.sin(math.abs(-math.pi + (globals.realtime() * (1 / 0.5)) % (math.pi * 2))) * 255 
    renderer.text(x,y + 20,179,230,0,255,"cb-",0,"KaNo yaw")
    if ui.get(angle_state) ~= "Key" then
        renderer.text(x,y + 30,255,255,255,alpha,"cb-",0,ui.get(angle_state))
    else
        if ui.get(force_anti) then
            renderer.text(x,y + 30,255,255,255,alpha,"cb-",0,"Force AA")
        else
            if body_yaw > 0 then
                renderer.text(x,y + 30,255,255,255,alpha,"cb-",0,"right")
            else
                renderer.text(x,y + 30,255,255,255,alpha,"cb-",0,"left")
            end
        end
    end
    renderer.text(x,y + 40,255,255,255,ui.get(e_legit_peek) and client.key_state(0x45) and 255 or 70,"cb-",0,"E - peek")
    if ui.get(manual_state) == 1 then
        renderer.text(x - 70,y - 5,255,255,255,255,"c+",0,"⯇")
    elseif ui.get(manual_state) == 2 then
        renderer.text(x + 70,y - 5,255,255,255,255,"c+",0,"⯈")
    elseif ui.get(manual_state) == 3 then
        renderer.text(x ,y + 80,255,255,255,255,"c+",0,"▼")
    elseif ui.get(manual_state) == 0 then
        renderer.text(x + 70,y - 5,255,255,255,body_yaw > 0 and alpha or 70,"c+",0,"⯈")
        renderer.text(x - 70,y - 5,255,255,255,body_yaw < 0 and alpha or 70,"c+",0,"⯇")
    end
    
end
local function rage_fire(e)
    rage_fire_delay = false
    client.delay_call(3,function()
        rage_fire_delay = true
    end)
end

local function reset()
    ui.set_visible(enable_anti,true)
    ui.set_visible(pitch,true)
    ui.set_visible(yawbase,true)
    ui.set_visible(yaw,true)
    ui.set_visible(yaw_sli,true)
    ui.set_visible(jitter,true)
    ui.set_visible(jitter_sli,true)
    ui.set_visible(body,true)
    ui.set_visible(body_sli,true)
    ui.set_visible(free_body,true)
    ui.set_visible(lby,true)
    ui.set_visible(lby_limit,true)
    ui.set_visible(edge,true)
    ui.set_visible(freestand,true)
    ui.set_visible(freestand_key,true)
end

client.set_event_callback("setup_command",run_handle)
client.set_event_callback("paint",paint_indicator)
ui.set_callback(active,ui_visible)
client.set_event_callback("aim_fire",rage_fire)
client.set_event_callback("shutdown",reset)
local function init_callbacks()
    --[[ ui.set_callback(active, ui_visible) ]]
    ui.set_callback(active, handle_menu)
    ui.set_callback(active_anti, handle_menu)
    ui.set_callback(angle_state,handle_menu)
    for i=1, #config_names do
        ui.set_callback(rage[i].c_anti_yaw,handle_menu)
        ui.set_callback(rage[i].c_anti_state,handle_menu)
        ui.set_callback(rage[i].c_yaw, handle_menu)
        ui.set_callback(rage[i].c_jitter, handle_menu)
        ui.set_callback(rage[i].c_body, handle_menu)
        ui.set_callback(rage[i].c_anti_body, handle_menu)
    end
end
init_callbacks()