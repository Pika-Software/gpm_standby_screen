language.Add( "dots.render_disabled", "Render is disabled" )

Theme.Name = "Dots"
Theme.Description = "Funny flying dots on the screen and connects with other dots."

Theme.Dots = {}

do

    /*
        Directions:

        0 - Up
        1 - Down
        2 - Left
        3 - Right
        4 - Up-Left
        5 - Up-Right
        6 - Down-Left
        7 - Down-Right

    */

    local Directions = {
        [0] = Vector( 0, 1 ), -- Up
        [1] = Vector( 0, -1 ), -- Down
        [2] = Vector( 1, 0 ), -- Left
        [3] = Vector( -1, 0 ) -- Right
    }

    Directions[4] = Directions[0] + Directions[2] -- Up + Left
    Directions[5] = Directions[0] + Directions[3] -- Up + Right
    Directions[6] = Directions[1] + Directions[2] -- Down + Left
    Directions[7] = Directions[1] + Directions[3] -- Down + Right

    local dot = {}
    dot.__index = dot

    -- Pos
    do
        local zero_pos = Vector( 0, 0 )
        function dot:GetPos()
            return self.Position or zero_pos
        end
    end

    function dot:SetPos( vec )
        self.Position = vec
    end

    -- Direction
    function dot:GetDirectionID()
        return self.DirectionID or 0
    end

    function dot:GetDirection()
        return self.Direction or Directions[ 0 ]
    end

    do
        local math_random = math.random
        function dot:SetDirection( num )
            if (Directions[ num ] == nil) then
                num = math_random( #Directions )
            end

            self.DirectionID = num
            self.Direction = Directions[ num ]
        end
    end

    -- Size
    function dot:GetSize()
        return self.Size or 1
    end

    function dot:SetSize( size )
        self.Size = size
    end

    -- Color
    do
        local color_white = color_white
        function dot:GetColor()
            return self.Color or color_white
        end
    end

    function dot:SetColor( color )
        self.Color = color
    end

    -- Connect
    function dot:GetConnect()
        return self.Connected
    end

    function dot:SetConnect( dot )
        self.Connected = dot
    end

    -- Paint
    do

        local surface_DrawLine = surface.DrawLine
        local surface_DrawCircle = surface.DrawCircle
        local surface_SetDrawColor = surface.SetDrawColor

        function dot:Paint()
            local vec = self:GetPos()
            local color = self:GetColor()
            local dot2 = self:GetConnect()
            if (dot2 ~= nil) then
                local vec2 = dot2:GetPos()
                local size2 = dot2:GetSize()

                surface_SetDrawColor( color.r, color.g, color.b, self.LineAlpha or 255 )
                surface_DrawLine( vec[1], vec[2], vec2[1], vec2[2] )
            end

            surface_DrawCircle( vec[1], vec[2], self:GetSize(), color )
        end

    end

    -- Movement
    do

        local left_dirs = {2, 4, 6}
        local right_dirs = {3, 5, 7}

        local up_dirs = {0, 4, 5}
        local down_dirs = {1, 6, 7}

        local table_Random = table.Random
        function dot:Move( w, h )
            local pos = self:GetPos() - self:GetDirection()
            local size = self:GetSize()

            if (pos[1] > w - size) then
                self:SetDirection( table_Random( left_dirs ) )
                return
            end

            if (pos[1] < size) then
                self:SetDirection( table_Random( right_dirs ) )
                return
            end

            if (pos[2] > h - size) then
                self:SetDirection( table_Random( up_dirs ) )
                return
            end

            if (pos[2] < size) then
                self:SetDirection( table_Random( down_dirs ) )
                return
            end

            self:SetPos( pos )
        end

    end

    -- Creating
    do

        local ScrW = ScrW
        local ScrH = ScrH
        local Vector = Vector
        local math_random = math.random
        local setmetatable = setmetatable

        function Theme:CreateDot( w, h, color )
            local new = setmetatable( {}, dot )
            new.__index = new

            if (color ~= nil) then
                new:SetColor( color )
            end

            new:SetDirection( math_random( #Directions ) )
            new:SetPos( Vector( math_random( w or ScrW() ), math_random( h or ScrH() ) ) )
            new:SetSize( 5 )

            return new
        end

    end

end

Theme.Styles = {
    [0] = {
        ["Colors"] = {
            ["Main"] = Color( 50, 50, 50 ),
            ["Dots"] = Color( 20, 20, 20 ),
            ["Text"] = Color( 100, 100, 100 ),
            ["TextShadow"] = Color( 40, 40, 40 )
        },
        ["Text"] = {
            ["Font"] = "DermaLarge"
        }
    },
    [1] = {
        ["Colors"] = {
            ["Main"] = Color( 0, 120, 150 ),
            ["Dots"] = Color( 190, 190, 190),
            ["Text"] = Color( 0, 200, 225),
            ["TextShadow"] = Color( 0, 80, 100 )
        },
        ["Text"] = {
            ["Font"] = "DermaLarge"
        }
    },
    [2] = {
        ["Colors"] = {
            ["Main"] = Color( 50, 50, 50 ),
            ["Dots"] = Color( 0, 120, 150 ),
            ["Text"] = Color( 0, 150, 170 ),
            ["TextShadow"] = Color( 40, 40, 40 )
        },
        ["Text"] = {
            ["Font"] = "DermaLarge"
        }
    },
    [3] = {
        ["Colors"] = {
            ["Main"] = Color( 50, 50, 50 ),
            ["Dots"] = Color( 0, 150, 25 ),
            ["Text"] = Color( 0, 180, 50 ),
            ["TextShadow"] = Color( 40, 40, 40 )
        },
        ["Text"] = {
            ["Font"] = "DermaLarge"
        }
    },
    [4] = {
        ["Colors"] = {
            ["Main"] = Color( 50, 50, 50 ),
            ["Dots"] = Color( 230, 30, 230 ),
            ["Text"] = Color( 270, 70, 270 ),
            ["TextShadow"] = Color( 40, 40, 40 )
        },
        ["Text"] = {
            ["Font"] = "DermaLarge"
        }
    },
    [5] = {
        ["Colors"] = {
            ["Main"] = Color( 50, 50, 50 ),
            ["Dots"] = color_white,
            ["Text"] = color_white,
            ["TextShadow"] = Color( 40, 40, 40 )
        },
        ["Text"] = {
            ["Font"] = "DermaLarge"
        },
        ["Rainbow"] = true,
        ["RainbowText"] = true
    },
    [6] = {
        ["Colors"] = {
            ["Main"] = Color( 50, 50, 50 ),
            ["Dots"] = color_white,
            ["Text"] = Color( 255, 0, 255 ),
            ["TextShadow"] = Color( 40, 40, 40 )
        },
        ["Text"] = {
            ["Font"] = "DermaLarge"
        },
        ["Overflow"] = true
    }
}

function Theme:SetStyle( num )
    local style = self.Styles[ num ]
    if (style == nil) then
        style = math.random( #self.Styles )
    end

    self.Color = style.Colors.Main
    self.DotColor = style.Colors.Dots
    self.TextColor = style.Colors.Text
    self.TextShadowColor = style.Colors.TextShadow

    self.Text = language.GetPhrase( utf8.force( CreateClientConVar( "dot_standby_screen_text", "#dots.render_disabled", true, false, " - Text on standby screen." ):GetString() ) )
    cvars.AddChangeCallback("dot_standby_screen_text", function( name, old, new )
        self.Text = language.GetPhrase( utf8.force( new ) )
    end, self.Name)

    self.TextFont = style.Text.Font

    self.Rainbow = style.Rainbow or false
    self.RainbowText = style.RainbowText or false
    self.Overflow = style.Overflow or false
end

do

    local table_insert = table.insert
    local ScreenScale = ScreenScale
    local tonumber = tonumber

    function Theme:Init()
        self:SetStyle( CreateClientConVar("dot_standby_screen_style", "0", true, false, " - Style for dot standby screen.", 0, #self.Styles ):GetInt() )
        cvars.AddChangeCallback("dot_standby_screen_style", function( name, old, new )
            self:SetStyle( tonumber( new ) )
            self:Init()
        end, self.Name)

        self.ConnectDist = ScreenScale( 35 )

        self.Dots = {}
        local w, h = standby_screen.GetResolution()
        for i = 1, ScreenScale( 35 ) do
            local dot = self:CreateDot( w, h, self.DotColor )
            dot.ConnectDist = self.ConnectDist
            table_insert( self.Dots, dot )
        end
    end

end

do
    local ipairs = ipairs
    local CurTime = CurTime
    local HSVToColor = HSVToColor
    function Theme:Think()
        if standby_screen.IsActive() then
            for num, dot in ipairs( self.Dots ) do
                local w, h = standby_screen.GetResolution()
                dot:Move( w, h )

                if (self.Rainbow) then
                    dot:SetColor( HSVToColor( ((dot:GetPos()[1] / w ) + ( dot:GetPos()[2] / h)) * 180, 1, 1 ) )
                end

                if (self.Overflow) then
                    dot:SetColor( Color( dot:GetPos()[1] / w * 255, 0, 255 - dot:GetPos()[1] / w * 255 ) )
                end

                local connected = dot:GetConnect()
                if (connected == nil) then
                    local pos1 = dot:GetPos()
                    for num2, dot2 in ipairs( self.Dots ) do
                        if (dot == dot2) then continue end
                        if ( pos1:Distance( dot2:GetPos() ) < self.ConnectDist) then
                            if (dot2:GetConnect() == dot) then continue end
                            dot:SetConnect( dot2 )
                            break
                        end
                    end
                else

                    local dist = dot:GetPos():Distance( connected:GetPos() )
                    if ( dist >= self.ConnectDist ) then
                        dot:SetConnect()
                        return
                    end

                    dot.LineAlpha = 255 - (dist / self.ConnectDist * 255)

                end
            end
        end
    end
end

do

    local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

    local ipairs = ipairs
    local CurTime = CurTime
    local utf8_sub = utf8.sub
    local HSVToColor = HSVToColor
    local draw_DrawText = draw.DrawText
    local surface_SetFont = surface.SetFont
    local surface_DrawText = surface.DrawText
    local surface_DrawRect = surface.DrawRect
    local surface_SetTextPos = surface.SetTextPos
    local surface_SetMaterial = surface.SetMaterial
    local surface_GetTextSize = surface.GetTextSize
    local surface_SetDrawColor = surface.SetDrawColor
    local surface_SetTextColor = surface.SetTextColor
    local surface_DrawTexturedRect = surface.DrawTexturedRect
    local render_UpdateScreenEffectTexture = render.UpdateScreenEffectTexture

    local blur_var = "$blur"
    local color_white = color_white
    local blur_material = Material( "pp/blurscreen" )

    local blur = CreateClientConVar( "dot_standby_screen_blur", "1", true, false, " - Enables blur on standby screen.", 0, 1 ):GetBool()
    cvars.AddChangeCallback("dot_standby_screen_blur", function( name, old, new )
        blur = new == "1"
    end, Theme.Name)

    function Theme:Paint( w, h )
        -- Background
        surface_SetDrawColor( self.Color )
        surface_DrawRect( 0, 0, w, h )

        -- Text Shadow
        draw_DrawText( self.Text, self.TextFont, w / 2 - 3, h / 2 - 2, self.TextShadowColor, TEXT_ALIGN_CENTER )

        for num, dot in ipairs( self.Dots ) do
            dot:Paint()
        end

        -- Blur
        if (blur) then
            surface_SetMaterial( blur_material )
            surface_SetDrawColor( color_white )

            for i = 0.33, 1, 0.33 do
                blur_material:SetFloat( blur_var, 2.5 * i )
                blur_material:Recompute()
                render_UpdateScreenEffectTexture()
                surface_DrawTexturedRect( 0, 0 , w, h )
            end

            surface_SetDrawColor( 0, 0, 0, 100 * 0.5 )
            surface_DrawRect( 0, 0, w, h )
        end

        -- Text
        local x, y = w / 2, h / 2
        surface_SetFont( self.TextFont )
        local w, h = surface_GetTextSize( self.Text )
        surface_SetTextPos( x - w / 2, y - h / 2 )

        if (self.RainbowText) then
            for i = 1, #self.Text do
                surface_SetTextColor( HSVToColor( ( i * 360 / w + (CurTime() * 15)) % 360, 1, 0.8 ) )
                surface_DrawText( utf8_sub( self.Text, i, i ) )
            end
        else
            surface.SetTextColor( self.TextColor )
            surface.DrawText( self.Text )
        end

    end

end

function Theme:OnRemove()
end
