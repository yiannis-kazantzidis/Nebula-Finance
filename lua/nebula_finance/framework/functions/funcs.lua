local blur = Material("pp/blurscreen")
function NebulaFinance:DrawBlurPanel(panel, layers, density, alpha)
    local x, y = panel:LocalToScreen(0, 0)

    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(blur)

    for i = 1, 3 do
        blur:SetFloat("$blur", (i / layers) * density)
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    end
end

function NebulaFinance:FormatValue(money)
    local priceText = (tonumber(money) > 0 and (DarkRP and DarkRP.formatMoney(tonumber(money))) or "$ " .. tonumber(money)) or "0"

    if (#tostring(math.Round(money)) > 8) then 
        priceText = DarkRP.formatMoney(math.Round(money / 1000000000, 2)) .. "Bil"
    elseif (#tostring(math.Round(money)) > 6) then
        priceText = DarkRP.formatMoney(math.Round(money / 1000000, 2)) .. "Mil"
    elseif (#tostring(math.Round(money)) > 3) then
        priceText = DarkRP.formatMoney(math.Round(money / 1000, 2)) .. "k"
    end

    return priceText
end

function NebulaFinance:Derma_Query(strText, strTitle, ...)
	local Window = vgui.Create( "DFrame" )
	Window:SetTitle( strTitle or "Message Title (First Parameter)" )
	Window:SetDraggable( false )
	Window:ShowCloseButton( false )
	Window:SetBackgroundBlur( true )
	Window:SetDrawOnTop( true )

    Window.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("frame"))
    end

	local InnerPanel = vgui.Create( "DPanel", Window )
	InnerPanel:SetPaintBackground( false )

	local Text = vgui.Create( "DLabel", InnerPanel )
	Text:SetText( strText or "Message Text (Second Parameter)" )
    Text:SetTextColor(color_white)
    Text:SetFont("NebulaFinance:Fonts:Small")
	Text:SizeToContents()
	Text:SetContentAlignment(5)

	local ButtonPanel = vgui.Create( "DPanel", Window )
	ButtonPanel:SetTall(30)
    ButtonPanel:SetPaintBackground(false)

	-- Loop through all the options and create buttons for them.
	local NumOptions = 0
	local x = 5

	for k = 1, 8, 2 do

		local Text = select( k, ... )
		if Text == nil then break end

		local Func = select( k+1, ... ) or function() end

		local Button = vgui.Create( "DButton", ButtonPanel )
		Button:SetText( Text )
        Button:SetTextColor(color_white)
        Button:SetFont("NebulaFinance:Fonts:Small")
		Button:SizeToContents()
		Button:SetTall( 25 )
		Button:SetWide( Button:GetWide() + 20 )
		Button.DoClick = function() Window:Close() Func() end
		Button:SetPos( x, 5 )

        Button.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox"))
        end

		x = x + Button:GetWide() + 5

		ButtonPanel:SetWide( x )
		NumOptions = NumOptions + 1

	end

	local w, h = Text:GetSize()

	w = math.max( w, ButtonPanel:GetWide() )

	Window:SetSize( w + 50, h + 25 + 45 + 10 )
	Window:Center()

	InnerPanel:StretchToParent( 5, 25, 5, 45 )

	Text:StretchToParent( 5, 5, 5, 5 )

	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom( 8 )

	Window:MakePopup()
	Window:DoModal()

	if ( NumOptions == 0 ) then

		Window:Close()
		Error( "Derma_Query: Created Query with no Options!?" )
		return nil

	end

	return Window
end

function NebulaFinance:Scale(value)
    return value * math.Clamp(ScrH() / 1080, 0.7, 1)
end