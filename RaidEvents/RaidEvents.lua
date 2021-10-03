local frame = CreateFrame("Frame", "RaidEvents", UIParent)

function frame:print(message)
  self.messageFrame:AddMessage(message)
end

local function DBMEventHandler(event, mod)
  if event == "kill" or event == "wipe" then
    RaidEvents:print(mod.combatInfo.name .. " combat ended.")
  elseif event == "pull" then
    RaidEvents:print(mod.combatInfo.name .. " combat started.")
  end
end

function frame:GetChatWindowId()
  for i = 1, NUM_CHAT_WINDOWS do
    local windowname = select(1, GetChatWindowInfo(i))
    if windowname == "RaidEvents" then
      return i
    end
  end
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_ENTERING_WORLD" then
    local windowId = self.GetChatWindowId()
    if windowId then
      SetChatWindowDocked(windowId, windowId)
      self.messageFrame = _G["ChatFrame"..windowId]
    end
    if not self.messageFrame then
      local chatframe = FCF_OpenNewWindow("RaidEvents")
      ChatFrame_RemoveAllMessageGroups(chatframe)
      ChatFrame_RemoveAllChannels(chatframe)
      self.messageFrame = _G["ChatFrame"..self.GetChatWindowId()]
    end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
  end
end)

DBM:RegisterCallback("pull", DBMEventHandler)
DBM:RegisterCallback("kill", DBMEventHandler)
DBM:RegisterCallback("wipe", DBMEventHandler)