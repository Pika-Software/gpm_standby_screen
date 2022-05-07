local theme_path = "packages/standby_screen/themes/"

if (SERVER) then
    local files = file.Find( theme_path .. "*", "LUA" )
    for num, name in ipairs( files ) do
        AddCSLuaFile( theme_path .. name )
    end

    return
end

local packageName = "Standby Screen"
local logger = GPM.Logger( packageName )

module( "standby_screen", package.seeall )

-- Screen Table
local themes = {}
function GetAll()
    return themes
end

-- Theme Metatable
do

    local theme = {}
    theme.__index = theme

    function theme:Paint( w, h )
    end

    function theme:Think()
    end

    function theme:Init()
    end

    function theme:OnRemove()
    end

    function isStandbyTheme( any )
        return getmetatable( any ) == theme
    end

    function Create( theme )
        local new = setmetatable( theme, theme )
        themes[ theme.Name ] = new
        return new
    end

    function Remove( name )
        themes[ name ] = nil
    end

end

-- Screen Resolution
do

    local width, height = 0, 0
    function GetResolution()
        return width, height
    end

    function SetResolution( w, h )
        logger:debug( "New screen resolution detected! ({1} x {2})", w, h )
        width, height = w, h
    end

    hook.Add("OnScreenSizeChanged", packageName, function()
        SetResolution( ScrW(), ScrH() )
        local current = GetCurrent()
        if (current == nil) then return end
        current:Init()
    end)

    SetResolution( ScrW(), ScrH() )

end

-- FPS Controller
do

    local min_fps = CreateClientConVar("standby_screen_fps", "30", true, true, " - Standby screen frame time." ):GetInt()
    cvars.AddChangeCallback("standby_screen_fps", function( name, old, new ) min_fps = tonumber( new ) end, packageName)

    function GetMinimalFPS()
        return min_fps
    end

    hook.Add("GameFocusChanged", "FpsController", function( has_focus )
        if (has_focus) then
            if (CLIENT_FPS == nil) then return end
            RunConsoleCommand( "fps_max", CLIENT_FPS )
        else
            CLIENT_FPS = cvars.Number( "fps_max", 75 )
            RunConsoleCommand( "fps_max", min_fps )
        end
    end)

end

-- Game Window Detector
do

    local opened = false
    function IsActive()
        if (opened) then
            return false
        end

        return true
    end

    do

        local SysTime = SysTime
        local hook_Run = hook.Run
        local system_HasFocus = system.HasFocus

        local next_think = 0
        local delay = GetMinimalFPS() / 1000

        hook.Add("Think", packageName, function()
            local has_focus = system_HasFocus()
            if (opened ~= has_focus) then
                logger:debug( "The game is {1}.", has_focus and "focused" or "in the tray" )
                hook_Run( "GameFocusChanged", has_focus )
                if (has_focus == false) then
                    delay = GetMinimalFPS() / 1000
                end

                opened = has_focus
            end

            if IsActive() and (next_think < SysTime()) then
                next_think = SysTime() + delay
                local current = GetCurrent()
                if (current == nil) then return end
                current:Think()
            end
        end)

    end

end

-- Themes
do

    function GetThemes()
        local files = file.Find( theme_path .. "*", "LUA" )
        return files
    end

end

-- Render Scene
do

    local current = nil
    function GetCurrent()
        return current
    end

    function Select( name )
        if (name == "none") or (name == "nil") then
            logger:info( "Selected new standby screen: {1}", name )
            current = nil
            return
        end

        if (themes[ name ] == nil) then
            name = "Dots"
        end

        local screen = themes[ name ]
        if (screen ~= nil) and (screen ~= current) then
            if (current ~= nil) then
                current:OnRemove()
            end

            screen:Init()
            current = screen
            logger:info( "Selected new standby screen: {1}", name )
        end
    end

    do

        local enabled = CreateClientConVar("standby_screen", "1", true, true, " - Enable standby screen.", 0, 1 ):GetBool()
        cvars.AddChangeCallback("standby_screen", function( name, old, new ) enabled = new == "1" end, packageName)

        local fade = CreateClientConVar("standby_screen_fade", "1", true, false, " - Enables standby screen fade.", 0, 1 ):GetBool()
        cvars.AddChangeCallback("standby_screen_fade", function( name, old, new ) fade = new == "1" end, packageName)

        local fade_speed = CreateClientConVar("standby_screen_fade_speed", "1", true, false, " - Standby screen fade speed.", 0, 1 ):GetFloat()
        cvars.AddChangeCallback("standby_screen_fade_speed", function( name, old, new ) fade_speed = tonumber( new ) end, packageName)

        local surface_SetAlphaMultiplier = surface.SetAlphaMultiplier
        local GetResolution = GetResolution
        local cam_Start2D = cam.Start2D
        local cam_End2D = cam.End2D
        local IsActive = IsActive

        local alpha = 0
        hook.Add("RenderScene", packageName, function()
            if (enabled) then
                if IsActive() then
                    if (current ~= nil) and (fade) and (alpha ~= 0) then
                        alpha = 0
                    end

                    return true
                elseif (fade) and (alpha < 1) then
                    alpha = alpha + 0.02 * fade_speed
                    surface_SetAlphaMultiplier( alpha )
                end
            end
        end)

        hook.Add("DrawOverlay", packageName, function()
            if (fade) and (alpha < 1) or IsActive() then
                if (current ~= nil) then
                    cam_Start2D()
                        surface_SetAlphaMultiplier( 1 - alpha )
                        current:Paint( GetResolution() )
                    cam_End2D()
                end
            end
        end)

    end

end

-- Adding Themes on Client
do

    local table_Copy = table.Copy
    local pcall = pcall

    local env = table_Copy( _G )

    for num, fl in ipairs( GetThemes() ) do
        local func = CompileFile( theme_path .. fl )

        env.Theme = {}
        setfenv( func, env )

        local ok, err = pcall( func )
        if (ok) then
            local theme = env.Theme
            if (theme == nil) then
                logger:warn( "Theme loading failed: `{1}`\nReturn nil!?", fl )
                return
            end

            Create( table_Copy( theme ) )
            logger:info( "Theme successfully loaded: `{1}`", theme.Name )
        else
            logger:warn( "Theme loading failed: `{1}`\n{2}", fl, err )
        end

        env.Theme = nil
    end

end

Select( CreateClientConVar("standby_screen_theme", "Dots", true, true, " - Standby screen theme." ):GetString() )
cvars.AddChangeCallback("standby_screen_theme", function( name, old, new ) Select( new ) end, packageName)

concommand.Add("standby_screen_reload", function()
    include( "packages/standby_screen/main.lua" )
end)

concommand.Add("standby_screen_themes", function()
    local num = 0
    for name, data in pairs( GetAll() ) do
        num = num + 1
        logger:info( "{1}. {2}", num, name )
    end
end)