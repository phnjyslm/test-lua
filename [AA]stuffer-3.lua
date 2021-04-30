--========================[ ANTI-AIM ]========================--
local ffi = require("ffi")
local ffi_cache = {}
local invoke_cache = function(b,c,d)local e=function(f,g,h)local i={[0]='always on',[1]='on hotkey',[2]='toggle',[3]='off hotkey'}local j=tostring(f)local k=ui.get(f)local l=type(k)local m,n=ui.get(f)local o=n~=nil and n or(l=='boolean'and tostring(k)or k)ffi_cache[j]=ffi_cache[j]or o;if g then ui.set(f,n~=nil and i[h]or h)else if ffi_cache[j]~=nil then local p=ffi_cache[j]if l=='boolean'then if p=='true'then p=true end;if p=='false'then p=false end end;ui.set(f,n~=nil and i[p]or p)ffi_cache[j]=nil end end end;if type(b)=='table'then for q,r in pairs(b)do e(q,r[1],r[2])end else e(b,c,d)end end


local antiaim_partitions = ui.new_combobox( "AA", "Anti-aimbot angles", "Anti-aimbot conditions", { "Standing", "Running", "Slow motion", "Crouched", "In air", "Manual LEFT", "Manual RIGHT" } )
local left_side = ui.new_slider("AA", "Anti-aimbot angles", "Left side fake limit", 0, 60, 60)
local right_side = ui.new_slider("AA", "Anti-aimbot angles", "Right side fake limit", 0, 60, 60)
local antiaim_switch = ui.new_hotkey( "AA", "Anti-aimbot angles", "Swap body yaw side" )
local fake_jitter = ui.new_hotkey( "AA", "Anti-aimbot angles", "Jitter fake yaw limit" )
local manual_partition = ui.new_hotkey( "AA", "Anti-aimbot angles", "Force manual condition" )

local manual_left = ui.new_hotkey("AA", "Anti-aimbot angles", "Manual side LEFT")
local manual_right = ui.new_hotkey("AA", "Anti-aimbot angles", "Manual side RIGHT")
local manual_back = ui.new_hotkey("AA", "Anti-aimbot angles", "Manual side BACK")

local manual = 0
local manual_l = nil
local manual_r = nil
local manual_b = nil

local doubletap, doubletap_key = ui.reference( "Rage", "Other", "Double tap" )
local pitch = ui.reference( "AA", "Anti-aimbot angles", "Pitch" )
local base = ui.reference( "AA", "Anti-aimbot angles", "Yaw base" )
local yaw, yaw_value = ui.reference( "AA", "Anti-aimbot angles", "Yaw" )
local yaw_jitter, yaw_jitter_value = ui.reference( "AA", "Anti-aimbot angles", "Yaw jitter" )
local body_yaw, body_yaw_value = ui.reference( "AA", "Anti-aimbot angles", "Body yaw" )
local auto_body_yaw = ui.reference( "AA", "Anti-aimbot angles", "Freestanding body yaw" )
local lby_target = ui.reference( "AA", "Anti-aimbot angles", "Lower body yaw target" )
local fake_limit = ui.reference( "AA", "Anti-aimbot angles", "Fake yaw limit" )
local edge_yaw = ui.reference( "AA", "Anti-aimbot angles", "Edge yaw" )
local freestanding, freestanding_key = ui.reference( "AA", "Anti-aimbot angles", "Freestanding" )
local slowmotion, slowmotion_key = ui.reference( "AA", "Other", "Slow motion" )

local partitions =
{
	[ "stand" ] =
	{
		[ 0 ] = "Off",
		[ 1 ] = "Local view",
		[ 2 ] = "Off",
		[ 3 ] = 0,
		[ 4 ] = "Off",
		[ 5 ] = 0,
		[ 6 ] = "Off",
		[ 7 ] = 0,
		[ 8 ] = false,
		[ 9 ] = "Off",
		[ 10 ] = 0,
		[ 11 ] = false,
		[ 12 ] = { }	
	},
	
	[ "run" ] =
	{
		[ 0 ] = "Off",
		[ 1 ] = "Local view",
		[ 2 ] = "Off",
		[ 3 ] = 0,
		[ 4 ] = "Off",
		[ 5 ] = 0,
		[ 6 ] = "Off",
		[ 7 ] = 0,
		[ 8 ] = false,
		[ 9 ] = "Off",
		[ 10 ] = 0,
		[ 11 ] = false,
		[ 12 ] = { }	
	},
	
	[ "slowmo" ] =
	{
		[ 0 ] = "Off",
		[ 1 ] = "Local view",
		[ 2 ] = "Off",
		[ 3 ] = 0,
		[ 4 ] = "Off",
		[ 5 ] = 0,
		[ 6 ] = "Off",
		[ 7 ] = 0,
		[ 8 ] = false,
		[ 9 ] = "Off",
		[ 10 ] = 0,
		[ 11 ] = false,
		[ 12 ] = { }	
	},
	
	[ "crouch" ] =
	{
		[ 0 ] = "Off",
		[ 1 ] = "Local view",
		[ 2 ] = "Off",
		[ 3 ] = 0,
		[ 4 ] = "Off",
		[ 5 ] = 0,
		[ 6 ] = "Off",
		[ 7 ] = 0,
		[ 8 ] = false,
		[ 9 ] = "Off",
		[ 10 ] = 0,
		[ 11 ] = false,
		[ 12 ] = { }	
	},
	
	[ "air" ] =
	{
		[ 0 ] = "Off",
		[ 1 ] = "Local view",
		[ 2 ] = "Off",
		[ 3 ] = 0,
		[ 4 ] = "Off",
		[ 5 ] = 0,
		[ 6 ] = "Off",
		[ 7 ] = 0,
		[ 8 ] = false,
		[ 9 ] = "Off",
		[ 10 ] = 0,
		[ 11 ] = false,
		[ 12 ] = { }	
	},
	
	[ "manual_lf" ] =
	{
		[ 0 ] = "Off",
		[ 1 ] = "Local view",
		[ 2 ] = "Off",
		[ 3 ] = 0,
		[ 4 ] = "Off",
		[ 5 ] = 0,
		[ 6 ] = "Off",
		[ 7 ] = 0,
		[ 8 ] = false,
		[ 9 ] = "Off",
		[ 10 ] = 0,
		[ 11 ] = false,
		[ 12 ] = { }	
	},

	[ "manual_rl" ] =
	{
		[ 0 ] = "Off",
		[ 1 ] = "Local view",
		[ 2 ] = "Off",
		[ 3 ] = 0,
		[ 4 ] = "Off",
		[ 5 ] = 0,
		[ 6 ] = "Off",
		[ 7 ] = 0,
		[ 8 ] = false,
		[ 9 ] = "Off",
		[ 10 ] = 0,
		[ 11 ] = false,
		[ 12 ] = { }	
	}
}

local antiaim =
{
	[ "active_partition_type" ] = "Standing",
	[ "last_active_partition_type" ] = "Standing",
	[ "inverted" ] = false,
	[ "did_store_lby_mode" ] = false,
	[ "stored_lby_mode" ] = "Opposite",
	[ "did_store_fake_limit" ] = false,
	[ "stored_fake_limit" ] = 0,
}

local ui_to_key =
{
	[ "Standing" ] = "stand", 
	[ "Running" ] = "run", 
	[ "Slow motion" ] = "slowmo",
	[ "Crouched" ] = "crouch",
	[ "In air" ] = "air",
	[ "Manual LEFT" ] = "manual_lf",
	[ "Manual RIGHT" ] = "manual_rl"
}

local num_to_key =
{
	[ 0 ] = "stand", 
	[ 1 ] = "run", 
	[ 2 ] = "slowmo",
	[ 3 ] = "crouch",
	[ 4 ] = "air",
	[ 5 ] = "manual_lf",
	[ 6 ] = "manual_rl",
}

local function vec_3( _x, _y, _z ) 
	return { x = _x or 0, y = _y or 0, z = _z or 0 } 
end

local vars = { }
local function setup( )
	local element_type = 0
	local final_number = 0
	for i = 0, 78 do
		if element_type < 6 then
			--client.log( num_to_key[ element_type ]..tostring( final_number ) )
			local key_name = num_to_key[ element_type ]..tostring( final_number )
			vars[ key_name ] = ui.new_label( "Lua", "B", key_name )
			if ui.get( vars[ key_name ] ) ~= key_name then
				partitions[ num_to_key[ element_type ] ][ final_number ] = ui.get( vars[ key_name ] )
			end
			ui.set_visible( vars[ key_name ], false )
		end
		
		if ( i + 1 ) % 13 == 0 then
			element_type = element_type + 1
			final_number = final_number - 13
		end
		final_number = final_number + 1
	end
end

setup( )

local function partition_change( reference )
	local partition_options = ui.get( reference )
	local selected_partition = ui_to_key[ partition_options ]
	local first_id = pitch

	ui.set( pitch, partitions[ selected_partition ][ pitch - first_id ] )
	ui.set( base, partitions[ selected_partition ][ base - first_id ] )
	ui.set( yaw, partitions[ selected_partition ][ yaw - first_id ] )
	ui.set( yaw_value, partitions[ selected_partition ][ yaw_value - first_id ] )
	ui.set( yaw_jitter, partitions[ selected_partition ][ yaw_jitter - first_id ] )
	ui.set( yaw_jitter_value, partitions[ selected_partition ][ yaw_jitter_value - first_id ] )
	ui.set( body_yaw, partitions[ selected_partition ][ body_yaw - first_id ] )
	ui.set( body_yaw_value, partitions[ selected_partition ][ body_yaw_value - first_id ] )
	ui.set( auto_body_yaw, partitions[ selected_partition ][ auto_body_yaw - first_id ] )
	ui.set( lby_target, partitions[ selected_partition ][ lby_target - first_id ] )
	ui.set( fake_limit, partitions[ selected_partition ][ fake_limit - first_id ] )
	ui.set( edge_yaw, partitions[ selected_partition ][ edge_yaw - first_id ] )
	ui.set( freestanding, partitions[ selected_partition ][ freestanding - first_id ] )
end

local function element_change( reference )
    if manual ~= 0 then
        return
    end
	local partition_element = ui.get( reference )
	local selected_partition = ui_to_key[ ui.get( antiaim_partitions ) ]
	local first_id = pitch

	partitions[ selected_partition ][ reference - first_id ] = ui.get( reference )
	
	local label_key = selected_partition..tostring( reference - first_id )
	ui.set( vars[ label_key ], tostring( ui.get( reference ) ) )
end

ui.set_callback( antiaim_partitions, partition_change )
ui.set_callback( pitch, element_change )
ui.set_callback( base, element_change )
ui.set_callback( yaw, element_change )
ui.set_callback( yaw_value, element_change )
ui.set_callback( yaw_jitter, element_change )
ui.set_callback( yaw_jitter_value, element_change )
ui.set_callback( body_yaw, element_change )
ui.set_callback( body_yaw_value, element_change )
ui.set_callback( auto_body_yaw, element_change )
ui.set_callback( lby_target, element_change )
ui.set_callback( fake_limit, element_change )
ui.set_callback( edge_yaw, element_change )
ui.set_callback( freestanding, element_change )

local function change_partition_type(  )
	if antiaim.last_active_partition_type ~= antiaim.active_partition_type then
		ui.set( antiaim_partitions, antiaim.active_partition_type )
	end
	
	antiaim.last_active_partition_type = antiaim.active_partition_type
end

local function leftkey_press(key) 
    if key and not manual_l then
        manual_l = true
        return true
    end
    
    if not key and manual_l then
        manual_l = false
    end
    return false
end

local function rightkey_press(key2) 
    if key2 and not manual_r then
        manual_r = true
        return true
    end
    
    if not key2 and manual_r then
        manual_r = false
    end
    return false
end
local function backkey_press(key3) 
    if key3 and not manual_b then
        manual_b = true
        return true
    end
    
    if not key3 and manual_b then
        manual_b = false
    end
    return false
end

client.set_event_callback( "setup_command", function( cmd )
	local velocity_prop = vec_3( entity.get_prop( entity.get_local_player( ), "m_vecVelocity" ) )
	local velocity = math.sqrt( velocity_prop.x * velocity_prop.x + velocity_prop.y * velocity_prop.y )
	if ui.get( doubletap_key ) then
		if not antiaim.did_store_lby_mode then
			antiaim.stored_lby_mode = ui.get( lby_target )
			antiaim.did_store_lby_mode = true
		end
		
		ui.set( lby_target, "Eye yaw" )
	else
		if antiaim.did_store_lby_mode then
			ui.set( lby_target, antiaim.stored_lby_mode )
			antiaim.did_store_lby_mode = false
		end
	end
	
	-- Haha
	if ui.get( fake_jitter ) then
		if not antiaim.did_store_fake_limit then
			antiaim.stored_fake_limit = ui.get( fake_limit )
			antiaim.did_store_fake_limit = true
		end
		
		ui.set( fake_limit, ( cmd.command_number % 4 == 0 and 17 or 34 ) )
	else
		if antiaim.did_store_fake_limit then
			ui.set( fake_limit, antiaim.stored_fake_limit )
			antiaim.did_store_fake_limit = false
		end
	end
	
	if ui.get( manual_partition ) then
		antiaim.active_partition_type = antiaim.inverted and "Manual LEFT" or "Manual RIGHT"
	elseif bit.band( entity.get_prop( entity.get_local_player( ), "m_fFlags" ), bit.lshift( 1, 0 ) ) == 0 then
		antiaim.active_partition_type = "In air"
	elseif velocity > 4 and not ui.get( slowmotion_key ) and bit.band( entity.get_prop( entity.get_local_player( ), "m_fFlags" ), bit.lshift( 1, 0 ) ) == 1 and cmd.in_duck == 0  then
		antiaim.active_partition_type = "Running"
	elseif velocity > 4 and ui.get( slowmotion_key ) and bit.band( entity.get_prop( entity.get_local_player( ), "m_fFlags" ), bit.lshift( 1, 0 ) ) == 1 and cmd.in_duck == 0  then
		antiaim.active_partition_type = "Slow motion"
	elseif velocity <= 4 and bit.band( entity.get_prop( entity.get_local_player( ), "m_fFlags" ), bit.lshift( 1, 0 ) ) == 1 and cmd.in_duck == 0 then
		antiaim.active_partition_type = "Standing"
	elseif cmd.in_duck == 1 then
		antiaim.active_partition_type = "Crouched"
    end
    
    if leftkey_press(ui.get(manual_left)) then
        if manual ~= -1 then
            manual = -1
        else
            manual = 0
        end
    end
    if rightkey_press(ui.get(manual_right)) then
        if manual ~= 1 then
            manual = 1
        else
            manual = 0
        end
    end
    if backkey_press(ui.get(manual_back)) then
        if manual ~= 69 then
            manual = 69
        else
            manual = 0
        end
    end

    local anglestuff = 90 * (manual == 69 and 0 or manual)

    
    local yaw_offset = (manual == 69 and 0 or manual) * 90
    invoke_cache({
        [yaw_value] = {manual ~= 0, yaw_offset}
    })
	change_partition_type( )
	
	antiaim.inverted = ui.get( antiaim_switch )
    ui.set( body_yaw_value, ( antiaim.inverted and -180 or 180 ) )
    
end )
--========================[ INDICATORS ]========================--

local mindmg = ui.reference("RAGE", "Aimbot", "Minimum damage")

local showarrows = ui.new_checkbox("LUA", "B", "Show anti-aim arrows")
local noobarrows = ui.new_checkbox("LUA", "B", "Manual anti-aim arrows")
local fakearrows = ui.new_checkbox("LUA", "B", "Show triangles")
local _____ = ui.new_label("LUA", "B", "Theme color")
local clr_theme = ui.new_color_picker("LUA", "B", "Theme color", 173, 255, 0, 255)
local ______ = ui.new_label("LUA", "B", "Background color")
local clr_background = ui.new_color_picker("LUA", "B", "Background color", 10, 10, 10, 125)
local _______ = ui.new_label("LUA", "B", "Default color")
local clr_default = ui.new_color_picker("LUA", "B", "Default color", 0, 255, 255, 255)
local clr_invert = ui.new_checkbox("LUA", "B", "Invert colors")

local theme, bg, df = {}, {}, {}
local showdmg = false
local function outline(x, y, width, height, clear)
	local pc = {}
	renderer.line(x, y, x, y+height, bg.r, bg.g, bg.b, bg.a) -- left
	renderer.line(x, y, x+width, y, bg.r, bg.g, bg.b, bg.a) -- top
	renderer.line(x+width, y, x+width, y+height, bg.r, bg.g, bg.b, bg.a) -- right
	renderer.line(x, y+height, x+width, y+height, bg.r, bg.g, bg.b, bg.a) -- bot
	pc.r = clear and bg.r or theme.r
	pc.g = clear and bg.g or theme.g
	pc.b = clear and bg.b or theme.b
	pc.a = clear and bg.a or theme.a
	if ui.get(clr_invert) then
		renderer.line(x, y, x+width, y, pc.r, pc.g, pc.b, pc.a) -- top
	else
		renderer.line(x, y+height, x+width, y+height, pc.r, pc.g, pc.b, pc.a) -- bot
	end
end

local function setMath(int, max, declspec)
    local int = (int > max and max or int)
    local tmp = max / int;
    local i = (declspec / tmp)
    i = (i >= 0 and math.floor(i + 0.5) or math.ceil(i - 0.5))
    return i
end
local shot_circle = 0
local fix_out, fix_in, time_fix = -0.42, 0, 0

client.set_event_callback("weapon_fire", function (event)
    if client.userid_to_entindex(event.userid) ~= entity.get_local_player() then
        return
    end

    if -fix_out < globals.realtime() * time_fix then fix_in = globals.realtime() + fix_out end 
end)
local screen_size = {client.screen_size()}
local function is_inside(a, b, x, y, w, h)
	return a >= x and a <= w and b >= y and b <= h 
end

local pos = database.read('adaptive_weapon_position') or {200,500}
local tX, tY = pos[1], pos[2] 
local oX, oY, _d 
local drag_menu = function(x, y, w, h) 
	if not ui.is_menu_open() then
		return tX, tY 
	end 
	local mouse_down = client.key_state(0x01) 
	if mouse_down then 
		local X, Y = ui.mouse_position() 
		if not _d then 
			local w, h = x + w, y + h
			if is_inside(X, Y, x, y, w, h) then 
				oX, oY, _d = X - x, Y - y, true 
			end
		else 
			tX, tY = X - oX, Y - oY 
		end
	else 
		_d = false 
	end
	return tX, tY 
end

client.set_event_callback("paint", function (ctx)
    theme.r, theme.g, theme.b, theme.a = ui.get(clr_theme)
    bg.r, bg.g, bg.b, bg.a = ui.get(clr_background)
    df.r, df.g, df.b, df.a = ui.get(clr_default)

    local screen_size = {client.screen_size()}

    -- ⯇⯈⯆

    local cs = {client.screen_size()}
		
    local alpha = theme.a
    
    if entity.is_alive(entity.get_local_player()) then
        local cen_x, cen_y = (screen_size[1] * 0.5), (screen_size[2] * 0.5)
        time_fix = 255 * 0.04 * globals.frametime()

        local body_pos = entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11)
        local body_yaw = math.max(-60, math.min(60, body_pos*120-60+0.5))
    
        if fix_in > globals.realtime() then shot_circle = (setMath(fix_in - globals.realtime(), fix_out , 40) * 0.004) else shot_circle = 0 end  
    
        if ui.get(base) == "At targets" then
            local _, cyaw = client.camera_angles()
            local _, yaw = entity.get_prop(entity.get_local_player(), "m_angAbsRotation")
            renderer.circle_outline(cen_x + 10 / 5, cen_y, theme.r, theme.g, theme.b, theme.a, 70, (-yaw - body_yaw + cyaw) - 101 - shot_circle * 120, 0.08 + shot_circle * 0.65, 6)
        end

		if ui.get(showarrows) then
			if (antiaim.inverted == false) then
				if ui.get(noobarrows) then
					if ui.get(fakearrows) then
						local base_x, base_y = cs[1] / 2 - 28, cs[2] / 2 + 25
						renderer.triangle(base_x - 2, base_y + 5, base_x + 13, base_y + 10, base_x - 3, base_y - 10, theme.r, theme.g, theme.b, 70)
						local base_x, base_y = cs[1] / 2 + 27, cs[2] / 2 + 25
						renderer.triangle(base_x + 4, base_y + 5, base_x - 12, base_y + 10, base_x + 6, base_y - 10, theme.r, theme.g, theme.b, alpha)
					end

					renderer.text(cs[1] / 2 - 40, cs[2] / 2 - 3, theme.r, theme.g, theme.b,(manual == -1 and alpha or 70), "c+", 0, "\xe2\xaf\x87") -- ⯇ ⯈ ⯆
					renderer.text(cs[1] / 2 + 40, cs[2] / 2 - 3, theme.r, theme.g, theme.b,(manual == 1 and alpha or 70), "c+", 0, "\xe2\xaf\x88")
					renderer.text(cs[1] / 2, cs[2] / 2 + 37, theme.r, theme.g, theme.b, (manual == (0 or 69) and alpha or 70), "c+", 0, "\xe2\xaf\x86")
				else
					renderer.text(cs[1] / 2 - 40, cs[2] / 2 - 3, theme.r, theme.g, theme.b,alpha, "c+", 0, "\xe2\xaf\x87") -- ⯇ ⯈ ⯆
					renderer.text(cs[1] / 2 + 40, cs[2] / 2 - 3, theme.r, theme.g, theme.b,70, "c+", 0, "\xe2\xaf\x88")
					renderer.text(cs[1] / 2, cs[2] / 2 + 37, theme.r, theme.g, theme.b,70, "c+", 0, "\xe2\xaf\x86")
				end
			else
				if ui.get(noobarrows) then
					if ui.get(fakearrows) then
						local base_x, base_y = cs[1] / 2 - 28, cs[2] / 2 + 25
						renderer.triangle(base_x - 2, base_y + 5, base_x + 13, base_y + 10, base_x - 3, base_y - 10, theme.r, theme.g, theme.b, alpha)
						local base_x, base_y = cs[1] / 2 + 27, cs[2] / 2 + 25
						renderer.triangle(base_x + 4, base_y + 5, base_x - 12, base_y + 10, base_x + 6, base_y - 10, theme.r, theme.g, theme.b, 70)
					end

					renderer.text(cs[1] / 2 - 40, cs[2] / 2 - 3, theme.r, theme.g, theme.b,(manual == -1 and alpha or 70), "c+", 0, "\xe2\xaf\x87") -- ⯇ ⯈ ⯆
					renderer.text(cs[1] / 2 + 40, cs[2] / 2 - 3, theme.r, theme.g, theme.b,(manual == 1 and alpha or 70), "c+", 0, "\xe2\xaf\x88")
					renderer.text(cs[1] / 2, cs[2] / 2 + 37, theme.r, theme.g, theme.b, (manual == 0 and alpha or (manual == 69 and alpha or 70)), "c+", 0, "\xe2\xaf\x86")
				else
					renderer.text(cs[1] / 2 - 40, cs[2] / 2 - 3, theme.r, theme.g, theme.b,70, "c+", 0, "\xe2\xaf\x87") -- ⯇ ⯈ ⯆
					renderer.text(cs[1] / 2 + 40, cs[2] / 2 - 3, theme.r, theme.g, theme.b,alpha, "c+", 0, "\xe2\xaf\x88")
					renderer.text(cs[1] / 2, cs[2] / 2 + 37, theme.r, theme.g, theme.b,70, "c+", 0, "\xe2\xaf\x86")
				end
			end
		end
    else
        shot_circle = 0
    end

    local text = "BEAST-MODE LUA"
    local text_width = renderer.measure_text("", text)

    local width, height = text_width+5, 18
    local padding = 20

    local x = screen_size[1] - width - padding*2
    local y = padding

    renderer.gradient(x, y, width, height, bg.r, bg.g, bg.b, bg.a, 30, 30, 30, bg.a, true)
    outline(x, y, width, height)
	renderer.text(x + 2, y + 1, df.r, df.g, df.b, df.a, "", 0, text)
	
	local text_width, text_height = renderer.measure_text("", "MANUAL: XXXXX")
	local x, y = drag_menu(tX, tY, text_width, text_height * 2)


    renderer.text(x, y, df.r, df.g, df.b, df.a, "", 0, "DAMAGE: "..ui.get(mindmg))
    if manual ~= 0 then
        local side = (manual == 69 and "BACK" or manual == 1 and "RIGHT" or "LEFT")
        y = y + padding/2
        text_width = renderer.measure_text("", "MANUAL: XXXXX")

        renderer.text(x, y, df.r, df.g, df.b, df.a, "", 0, "MANUAL: "..side)
    end
end)

client.set_event_callback("shutdown", function ()
    database.write('adaptive_weapon_position', {tX, tY}) 
end)