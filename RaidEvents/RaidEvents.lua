local frame = CreateFrame("Frame", "RaidEvents", UIParent)
frame:SetFrameStrata("FULLSCREEN_DIALOG")
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true,
  tileSize = 32,
  edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0, 0, 0, .85)
frame:EnableMouse(true)
frame:EnableMouseWheel(true)

-- Make movable/resizable
frame:SetMovable(true)
frame:SetResizable(true)
frame:SetMinResize(100, 100)

--[[
local drag1 = CreateFrame("Frame", nil, frame)
drag1:SetSize(10,10)
drag1:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
drag1:RegisterForDrag("LeftButton")
]] --


frame:RegisterForDrag("LeftButton", "RightButton")
function frame:StartMovingOrSizing(button)
  if button == "LeftButton" then
    self:StartMoving()
  else
    self.isResizing = true
    self.scrollBar.offset = select(2, self.scrollBar:GetMinMaxValues()) - self.scrollBar:GetValue()
    self:StartSizing("BOTTOMRIGHT")
  end
end

function frame:OnDragStop()
  self:StopMovingOrSizing()
  self.isResizing = false
  self.scrollBar:update()
end

frame:SetScript("OnDragStart", frame.StartMovingOrSizing)
frame:SetScript("OnDragStop", frame.OnDragStop)

-- ScrollingMessageFrame
local messageFrame = CreateFrame("ScrollingMessageFrame", nil, frame)
messageFrame:SetPoint("CENTER", -2, 0)
messageFrame:SetSize(frame:GetWidth() - 20, frame:GetHeight() - 20)
messageFrame:SetFontObject(GameFontNormal) -- GameFontNormalLarge
messageFrame:SetTextColor(1, 1, 1, 1) -- default color
messageFrame:SetJustifyH("LEFT")
messageFrame:SetHyperlinksEnabled(true)
messageFrame:SetFading(false)
messageFrame:SetMaxLines(300)
frame.messageFrame = messageFrame

--messageFrame:ScrollToBottom()
--messageFrame:ScrollDown()
--print(messageFrame:GetNumMessages(), messageFrame:GetNumLinesDisplayed())

-------------------------------------------------------------------------------
-- Scroll bar
-------------------------------------------------------------------------------
local scrollBar = CreateFrame("Slider", nil, frame, "UIPanelScrollBarTemplate")
scrollBar:SetPoint("RIGHT", frame, "RIGHT", 8, 0)
scrollBar:SetSize(20, frame:GetHeight() - 35)
-- for some reason has to be here although values are set in update(), otherwise scrollbar cannot display
scrollBar:SetMinMaxValues(0, 9)
scrollBar:SetValueStep(1)
function scrollBar:update()
  if self:GetParent().messageFrame:GetNumMessages() > self:GetParent().messageFrame:GetNumLinesDisplayed() then
    local cur_val = self:GetValue()
    local max_val = select(2, self:GetMinMaxValues())
    self:SetMinMaxValues(0, self:GetParent().messageFrame:GetNumMessages() - self:GetParent().messageFrame:GetNumLinesDisplayed())
    if cur_val == max_val then
      self:SetValue(select(2, self:GetMinMaxValues()))
    elseif self.offset and not self:GetParent().isResizing then
      self:SetValue(select(2, self:GetMinMaxValues()) - self.offset)
      self.offset = nil
    end
    if not self:IsShown() then
      self:GetParent():SetScript("OnMouseWheel", function(self, delta)
        local cur_val = self.scrollBar:GetValue()
        local min_val, max_val = self.scrollBar:GetMinMaxValues()

        if delta < 0 and cur_val < max_val then
          cur_val = math.min(max_val, cur_val + 1)
          self.scrollBar:SetValue(cur_val)
        elseif delta > 0 and cur_val > min_val then
          cur_val = math.max(min_val, cur_val - 1)
          self.scrollBar:SetValue(cur_val)
        end
      end)
      self:Show()
    end
  elseif self:IsShown() then
    self:GetParent():SetScript("OnMouseWheel", nil)
    self:Hide()
  end
end

frame.scrollBar = scrollBar

function frame:print(message)
  local datetime = date('%H:%M:%S', time())
  table.insert(RaidEvents_SV.history, { datetime, message })
  self.messageFrame:AddMessage("[" .. datetime .. "] " .. message)
  self.scrollBar:update()
  --if select(2, self.scrollBar:GetMinMaxValues()) - self.scrollBar:GetValue() == 1 then
  --  self.scrollBar:SetValue(self.scrollBar:GetValue() + 1)
  --end
end

frame:SetScript("OnSizeChanged", function(self, w, h)
  self.messageFrame:SetSize(w - 20, h - 20)
  self.scrollBar:SetHeight(h - 35)
  self.scrollBar:update()
end)

frame.scrollBar:SetScript("OnValueChanged", function(self, value)
  self:GetParent().messageFrame:SetScrollOffset(select(2, self:GetMinMaxValues()) - value)
  self:update()
end)

frame.scrollBar:SetValue(select(2, frame.scrollBar:GetMinMaxValues()))

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
  if event == "PLAYER_ENTERING_WORLD" then
    self.scrollBar:update()
    RaidEvents:Show()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
  elseif event == "ADDON_LOADED" and arg1 == "RaidEvents" then
    RaidEvents_SV = RaidEvents_SV or {}
    RaidEvents_SV.frameWidth = RaidEvents_SV.frameWidth or 500
    RaidEvents_SV.frameHeight = RaidEvents_SV.frameHeight or 250
    self:SetSize(RaidEvents_SV.frameWidth, RaidEvents_SV.frameHeight)
    RaidEvents_SV.frameofsx = RaidEvents_SV.frameofsx or 0
    RaidEvents_SV.frameofsy = RaidEvents_SV.frameofsy or 0
    self:SetPoint("CENTER", RaidEvents_SV.frameofsx, RaidEvents_SV.frameofsy)
    RaidEvents_SV.history = RaidEvents_SV.history or {}
    if #RaidEvents_SV.history ~= 0 then
      if #RaidEvents_SV.history > self.messageFrame:GetMaxLines() then
        RaidEvents_SV.history= {unpack(RaidEvents_SV.history, #RaidEvents_SV.history - self.messageFrame:GetMaxLines() + 1, #RaidEvents_SV.history)}
      end
      for _, message in pairs(RaidEvents_SV.history) do
        if message[1] and message[2] then
          self.messageFrame:AddMessage("[" .. message[1] .. "] " .. message[2])
        end
      end
      self.scrollBar:update()
    end
    self:UnregisterEvent("ADDON_LOADED")
  end
end)

local function DBMEventHandler(event, mod)
  if event == "kill" or event == "wipe" then
    RaidEvents:print(mod.combatInfo.name .. " combat ended.")
  elseif event == "pull" then
    RaidEvents:print(mod.combatInfo.name .. " combat started.")
  end
end

DBM:RegisterCallback("pull", DBMEventHandler)
DBM:RegisterCallback("kill", DBMEventHandler)
DBM:RegisterCallback("wipe", DBMEventHandler)

SLASH_RE1 = "/re"
SlashCmdList.RE = function()
  if RaidEvents:IsShown() then
    RaidEvents:Hide()
  else
    RaidEvents:Show()
  end
end