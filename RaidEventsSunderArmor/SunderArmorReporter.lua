local f = CreateFrame("Frame");
f.playerlist = {}

local function sendmessage(text)
  --RaidEvents:print(text)
  --[[
  local raidIndex = UnitInRaid("player")
  if raidIndex ~= nil then
    local _, rank = GetRaidRosterInfo(raidIndex + 1)
    if rank >= 1 then
      SendChatMessage(text, "RAID")
	  return
    end
  end
  DEFAULT_CHAT_FRAME:AddMessage(text)
  ]] --
end

f:SetScript("OnEvent", function(self, _, ...)
  arg = { ... }
  if table.contains({ "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REFRESH", "SPELL_AURA_APPLIED" }, arg[2]) and arg[9] == 58567 then
    self.playerlist[arg[4]] = (self.playerlist[arg[4]] or 0) + 1
  end
end)

local function DBMEventHandler(event)
  if event == "kill" or event == "wipe" then
    local text = GetSpellLink(58567) .. ": "
    local next = next(f.playerlist)
    if not next then
      text = text .. "none"
    else
      for name, num in pairs(f.playerlist) do
        if name ~= next then
          text = text .. ", "
        end
        text = text .. UnitNameColored(name) .. "(" .. num .. ")"
      end
    end
    RaidEvents:print(text)
    f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    table.wipe(f.playerlist)
  elseif event == "pull" then
    table.wipe(f.playerlist)
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  end
end

DBM:RegisterCallback("pull", DBMEventHandler)
DBM:RegisterCallback("kill", DBMEventHandler)
DBM:RegisterCallback("wipe", DBMEventHandler)
