
local images = require 'gamesense/images'
local csgo_weapons = require 'gamesense/csgo_weapons'

local enable = ui.new_checkbox("lua","a","HUD")

local dragging = (function()local a={}local b,c,d,e,f,g,h,i,j,k,l,m,n,o;local p={__index={drag=function(self,...)local q,r=self:get()local s,t=a.drag(q,r,...)if q~=s or r~=t then self:set(s,t)end;return s,t end,set=function(self,q,r)local j,k=client.screen_size()ui.set(self.x_reference,q/j*self.res)ui.set(self.y_reference,r/k*self.res)end,get=function(self)local j,k=client.screen_size()return ui.get(self.x_reference)/self.res*j,ui.get(self.y_reference)/self.res*k end}}function a.new(u,v,w,x)x=x or 10000;local j,k=client.screen_size()local y=ui.new_slider('LUA','A',u..' window position',0,x,v/j*x)local z=ui.new_slider('LUA','A','\n'..u..' window position y',0,x,w/k*x)ui.set_visible(y,false)ui.set_visible(z,false)return setmetatable({name=u,x_reference=y,y_reference=z,res=x},p)end;function a.drag(q,r,A,B,C,D,E)if globals.framecount()~=b then c=ui.is_menu_open()f,g=d,e;d,e=ui.mouse_position()i=h;h=client.key_state(0x01)==true;m=l;l={}o=n;n=false;j,k=client.screen_size()end;if c and i~=nil then if(not i or o)and h and f>q and g>r and f<q+A and g<r+B then n=true;q,r=q+d-f,r+e-g;if not D then q=math.max(0,math.min(j-A,q))r=math.max(0,math.min(k-B,r))end end end;table.insert(l,{q,r,A,B})return q,r,A,B end;return a end)()
local hotkeys_dragging = dragging.new('cold_hud', 100, 800)

local rect_alpha = ui.new_slider("lua", "a", "Rect alpha", 0, 255, 155)

local health_color_label = ui.new_label("lua", "a", "Health color")
local health_color = ui.new_color_picker("lua", "a", "Health color", 255, 73, 73, 197)

local armor_color_label = ui.new_label("lua", "a", "Armor color")
local armor_color = ui.new_color_picker("lua", "a", "Armor color", 53, 131, 192, 197)

function draw_container(x, y, w, h)
    local c = {10, 60, 40, 40, 40, 60, 20}
    for i = 0,6,1 do
        renderer.rectangle(x+i, y+i, w-(i*2), h-(i*2), c[i+1], c[i+1], c[i+1], ui.get(rect_alpha))
    end
end

local function paint_hud()

--[[     if not ui.get(enable) then return end
 ]]
    if not entity.is_alive(entity.get_local_player()) then
        return
    end
    ui.set_visible(rect_alpha, ui.get(enable))
    ui.set_visible(health_color_label, ui.get(enable))
    ui.set_visible(health_color, ui.get(enable))
    ui.set_visible(armor_color_label, ui.get(enable))
    ui.set_visible(armor_color, ui.get(enable))
    if not ui.get(enable) then
        return
    end

    local local_player = entity.get_local_player()
    entity.set_prop(local_player, "m_iHideHud", 8200)  
    if local_player == nil then return end

    
    local weapon_ent = entity.get_player_weapon(local_player)
    local weapon_idx = entity.get_prop(weapon_ent, "m_iItemDefinitionIndex")
    local weapon = csgo_weapons[weapon_idx]

    local c4_icon = images.get_weapon_icon("c4")
    local helmet_icons = images.get_weapon_icon("helmet")
    local armor_incons = images.get_weapon_icon("armor")
    local ammo_icons = images.load_svg('<?xml version="1.0" encoding="utf-8"?><svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="32" height="32"><g><g><path fill="#FFFFFF" d="M5,24.5l5.4,4.3l9.8-13c0.2-0.3,0.5-1.2,0.5-1.2s0.1-0.7,0.5-1.4c0.4-0.7,1.2-1.7,1.2-1.7l-3.7-3.1c0,0-1.6,1.5-1.8,1.7c-0.7,0.7-1.5,1-1.8,1.4S5,24.5,5,24.5z"/><polygon fill="#FFFFFF" points="19.3,7.8 23,10.8 27.9,1.8 26.6,0.7"/><path fill="#FFFFFF" d="M4.4,25.2l5.5,4.4l-0.5,0.5c0,0-2,0-3.7-1.3c-1.9-1.4-1.7-3.1-1.7-3.1L4.4,25.2z"/></g></g></svg>')
    local health_inons = images.load_svg('<svg t="1603681316124" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="6946" width="200" height="200"><path d="M678.661224 141.583673c-63.738776 0-123.297959 28.212245-166.661224 77.844898-43.885714-49.632653-103.967347-77.844898-167.183673-77.844898-126.955102 0-229.877551 112.326531-229.877551 250.253062 0 82.546939 37.616327 141.061224 64.783673 183.379592 82.02449 128.522449 286.302041 287.346939 295.183673 293.616326 10.971429 8.359184 23.510204 13.061224 37.616327 13.061225 13.583673 0 26.122449-4.179592 37.093878-13.061225 8.881633-6.791837 213.159184-165.093878 295.183673-294.138775l1.044898-1.567347c28.212245-44.930612 63.738776-100.832653 63.738775-181.812245-0.522449-137.404082-103.967347-249.730612-230.922449-249.730613z" fill="#E5404F" p-id="6947"></path><path d="M716.8 528.718367l-94.040816 94.040817-1.044898 1.044898c-4.179592 3.657143-9.926531 5.746939-15.67347 5.746938s-12.016327-2.089796-16.718367-6.791836L417.959184 451.395918l-77.322449 77.322449c-4.702041 4.702041-10.44898 6.791837-16.718368 6.791837s-12.016327-2.089796-16.718367-6.791837c-9.404082-9.404082-9.404082-24.032653 0-33.436734l94.040816-94.040817c9.404082-9.404082 24.032653-9.404082 33.436735 0l171.363265 171.363266 77.322449-77.322449c9.404082-9.404082 24.032653-9.404082 33.436735 0 9.404082 9.404082 9.404082 24.032653 0 33.436734z" fill="#FFEEF0" p-id="6948"></path></svg> ')
    local svg_fangdanyi = images.load_svg('<svg t="1615246340260" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="7831" width="200" height="200"><path d="M873.24 166.73a63.249 63.249 0 0 0-41.45-15.49c-3.09 0-6.19 0.23-9.28 0.69-17.85 2.65-36.21 4-54.57 4-83.65 0-161.29-27.4-213.02-75.17-12.13-11.21-27.53-16.81-42.92-16.81s-30.79 5.6-42.92 16.81c-51.73 47.77-129.37 75.17-213.02 75.17-18.36 0-36.72-1.34-54.57-4-3.09-0.46-6.19-0.69-9.28-0.69-15.11 0-29.85 5.43-41.45 15.49-13.96 12.11-21.99 29.73-21.99 48.27v419.4c0 9.73 2.22 19.33 6.48 28.06 21.59 44.27 45.73 84.72 71.72 120.23 26.92 36.77 56.11 68.6 86.76 94.62 32.45 27.55 66.88 48.87 102.33 63.38 37.68 15.42 76.69 23.24 115.95 23.24s78.27-7.82 115.95-23.24c35.45-14.51 69.87-35.83 102.33-63.38 30.65-26.02 59.84-57.85 86.76-94.62 26-35.51 50.13-75.96 71.73-120.24a64.03 64.03 0 0 0 6.48-28.06V215c-0.03-18.54-8.05-36.16-22.02-48.27zM831.8 634.4C752.04 797.92 638.27 900.19 512 900.19S271.97 797.92 192.2 634.4V215c20.66 3.07 42.01 4.68 63.85 4.68 103.05 0 195.12-35.81 255.95-91.98 60.83 56.17 152.9 91.98 255.95 91.98 21.84 0 43.19-1.61 63.85-4.68v419.4z" fill="#e6e6e6" p-id="7832"></path><path d="M671.78 392.84H612.1V328.6c0-38.77-31.38-70.31-69.96-70.31h-69.96c-38.58 0-69.96 31.54-69.96 70.31v64.24h-59.68c-38.58 0-69.96 31.54-69.96 70.31v70.31c0 38.77 31.38 70.31 69.96 70.31h59.68v134.55c0 38.77 31.38 70.31 69.96 70.31h69.96c38.58 0 69.96-31.54 69.96-70.31V603.78h59.68c38.58 0 69.96-31.54 69.96-70.31v-70.31c0-38.78-31.39-70.32-69.96-70.32z m0 140.62H542.14v204.86h-69.96V533.46H342.54v-70.31h129.64V328.6h69.96v134.55h129.64v70.31z" fill="#e6e6e6" p-id="7833"></path></svg>')
    local weapon_icon = images.get_weapon_icon(weapon)
    if weapon_icon == nil then
        return
    end
    
    local w,h = weapon_icon:measure() * 0.7
    local w1,h1 = ammo_icons:measure() * 0.7
    local w2,h2 = health_inons:measure() * 0.05


    local health = entity.get_prop(local_player, "m_iHealth")
    local first_ammo = entity.get_prop(entity.get_player_weapon(local_player), "m_iClip1") or -1
    local second_ammo = entity.get_prop(entity.get_player_weapon(local_player), "m_iPrimaryReserveAmmoCount") or 0
    local armor = entity.get_prop(local_player, "m_ArmorValue")
    local money = entity.get_prop(local_player, "m_iAccount")
    local has_helmet, has_defuser, has_kevlar = entity.get_prop(local_player, "m_bHasHelmet"), entity.get_prop(local_player, "m_bHasDefuser"), nil
    local playerresource = entity.get_all("CCSPlayerResource")[1]
    local c4 = entity.get_prop(playerresource, "m_iPlayerC4")
    if armor > 1 and armor <= 100 then
        has_kevlar = true
    else
        has_kevlar = false
    end


    local string_len = string.len(health)
    local frist_string = string.sub(health,-1,-1)
    local mid_string = string.sub(health,-2,-2)
    local last_string = string.sub(health,-3,-3)
    local x, y = hotkeys_dragging:get()
    draw_container(x,y,240,80)
    local armor_alpha = 30
    local offset = 0

    local player = entity.get_local_player()
    local steamid3 = entity.get_steam64(player)
    local avatar = images.get_steam_avatar(steamid3)
    
    if has_helmet == 1 then 
        helmet_icons:draw(x+5+80-5+25+72+30,   y+53, w2,h2, 255,255,255, 255,true, "f")
        armor_alpha = armor_alpha + 35
        offset = offset + w2
    end    

    if has_kevlar == true then       
        armor_incons:draw(x+5+80-5+25+72+offset+34,   y+54, w2,h2, 255,255,255, 255,true, "f")
        armor_alpha = armor_alpha + 35
    end 
    local text_index = "["..player.."]  "
    avatar:draw(x+6,y+6, 68, 68, 255, 255, 255, 255, true, "f")
    renderer.text(x+6+80-3,y+15,255,255,255,255,"b","nil",text_index)
    local text_index_w = renderer.measure_text("b", text_index)
    renderer.text(x+6+80-3+text_index_w,y+15,255,255,255,255,"b","nil",entity.get_player_name(player))
    health_inons:draw(x+6+80-5,    y+30,20,20, 255,0,0,255,true, "f")
    svg_fangdanyi:draw(x+5+80-5,   y+50,20,20, 255,255,255,armor_alpha/100*255,true, "f")
    renderer.rectangle(x+6+80-5+25,   y+35,100,10, 14,14,14,144)
    local h_r,h_g,h_b,h_a = ui.get(health_color)
    renderer.rectangle(x+6+80-5+25,   y+35,health / 100 * 100 > 100 and 100 or health / 100 * 100,10, h_r,h_g,h_b,h_a)
    renderer.text(x+6+80-5+25+102,   y+34,h_r,h_g,h_b,h_a,"b","nil",last_string.." "..mid_string.." "..frist_string)
    local a_r,a_g,a_b,a_a = ui.get(armor_color)
    renderer.rectangle(x+5+80-5+25,   y+55,70,10, 14,14,14,144)

    renderer.rectangle(x+5+80-5+25,   y+55,armor/100*70,10, a_r,a_g,a_b,a_a)
    frist_string = string.sub(armor,-1,-1)
    mid_string = string.sub(armor,-2,-2)
    last_string = string.sub(armor,-3,-3)
    renderer.text(x+5+80-5+25+72,   y+54,a_r,a_g,a_b,a_a,"b","nil",last_string.." "..mid_string.." "..frist_string)

    hotkeys_dragging:drag(240,80)
end

client.set_event_callback("paint",paint_hud)