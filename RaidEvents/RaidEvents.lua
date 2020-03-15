local frame = CreateFrame("Frame", "RaidEventsFrame", UIParent)
frame.width = 500
frame.height = 250
frame:SetFrameStrata("FULLSCREEN_DIALOG")
frame:SetSize(frame.width, frame.height)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true,
  tileSize = 32,
  edgeSize = 32,
  insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
frame:SetBackdropColor(0, 0, 0, 1)
frame:EnableMouse(true)
frame:EnableMouseWheel(true)

-- Make movable/resizable
frame:SetMovable(true)
frame:SetResizable(true)
frame:SetMinResize(100, 100)
frame:RegisterForDrag("LeftButton", "RightButton")
function frame:StartMovingOrSizing(button)
  if button == "LeftButton" then
    self:StartMoving()
  else
    self:StartSizing("BOTTOMRIGHT")
  end
end

frame:SetScript("OnDragStart", frame.StartMovingOrSizing)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

--tinsert(UISpecialFrames, "RaidEventsFrame")

-- Close button
local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
closeButton:SetPoint("BOTTOM", 0, 10)
closeButton:SetHeight(25)
closeButton:SetWidth(70)
closeButton:SetText(CLOSE)
closeButton:SetScript("OnClick", function(self)
  HideParentPanel(self)
end)
frame.closeButton = closeButton

-- ScrollingMessageFrame
RaidEvents = CreateFrame("ScrollingMessageFrame", nil, frame)
RaidEvents:SetPoint("CENTER", 15, 20)
RaidEvents:SetSize(frame.width, frame.height - 50)
RaidEvents:SetFontObject(GameFontNormal)
RaidEvents:SetTextColor(1, 1, 1, 1) -- default color
RaidEvents:SetJustifyH("LEFT")
RaidEvents:SetHyperlinksEnabled(true)
RaidEvents:SetFading(false)
RaidEvents:SetMaxLines(300)
function RaidEvents:print(message)
  self:AddMessage("[" .. date('%H:%M:%S', time()) .. "] " .. message)
end

frame.RaidEvents = RaidEvents

--RaidEvents:ScrollToBottom()
--RaidEvents:ScrollDown()
--print(RaidEvents:GetNumMessages(), RaidEvents:GetNumLinesDisplayed())

-------------------------------------------------------------------------------
-- Scroll bar
-------------------------------------------------------------------------------
local scrollBar = CreateFrame("Slider", nil, frame, "UIPanelScrollBarTemplate")
scrollBar:SetPoint("RIGHT", frame, "RIGHT", -10, 10)
scrollBar:SetSize(30, frame.height - 90)
scrollBar:SetMinMaxValues(0, 9)
scrollBar:SetValueStep(1)
scrollBar.scrollStep = 1
frame.scrollBar = scrollBar

frame:SetScript("OnSizeChanged", function(_, w, h)
  RaidEvents:SetSize(w, h - 50)
  scrollBar:SetSize(30, h - 90)
end)

scrollBar:SetScript("OnValueChanged", function(self, value)
  RaidEvents:SetScrollOffset(select(2, scrollBar:GetMinMaxValues()) - value)
end)

scrollBar:SetValue(select(2, scrollBar:GetMinMaxValues()))

frame:SetScript("OnMouseWheel", function(self, delta)
  --print(RaidEvents:GetNumMessages(), RaidEvents:GetNumLinesDisplayed())

  local cur_val = scrollBar:GetValue()
  local min_val, max_val = scrollBar:GetMinMaxValues()

  if delta < 0 and cur_val < max_val then
    cur_val = math.min(max_val, cur_val + 1)
    scrollBar:SetValue(cur_val)
  elseif delta > 0 and cur_val > min_val then
    cur_val = math.max(min_val, cur_val - 1)
    scrollBar:SetValue(cur_val)
  end
end)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self)
  RaidEventsFrame:Show()
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

SLASH_RE1 = "/re"
SlashCmdList.RE = function()
  if RaidEventsFrame:IsShown() then
    RaidEventsFrame:Hide()
  else
    RaidEventsFrame:Show()
  end
end