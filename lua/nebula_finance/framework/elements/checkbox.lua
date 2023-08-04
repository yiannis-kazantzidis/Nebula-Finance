local PANEL = {}

local noCol = Color(0, 0, 0, 0)
local offCol = Color(40, 40, 40)

function PANEL:Init(  )
   self:SetText("")
   self.value = nil
   self.Color = noCol
   self.text = ""
end

function PANEL:Paint(w, h)
  local nextColor = offCol
  if self.value and 1 then
      nextColor = NebulaFinance:GetTheme("green")
  end

  self.Color = NebulaFinance:LerpColor(FrameTime() * 10, self.Color, nextColor)

  draw.RoundedBox(4, 0, 0, w, h, self.Color)

  if self.value and 1 then
      self.text = "✔"
  else
      self.text = "✖"
  end
    
  draw.SimpleText(self.text, "NebulaFinance:Fonts:Small", w / 2, h / 12, NebulaFinance.GetTheme("text1"), TEXT_ALIGN_CENTER)
end

function PANEL:DoClick()
    self:SetValue(!self:GetValue())
end

function PANEL:OnStateChanged() end

function PANEL:GetValue()
    return self.value
end

function PANEL:SetValue(value)
    self.value = value

    self:OnStateChanged(value)
end

vgui.Register("NebulaFinance:Checkbox", PANEL, "DButton")