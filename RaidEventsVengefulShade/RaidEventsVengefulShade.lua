local f = CreateFrame("Frame")
f.explosions = {}

f:SetScript("OnEvent", function(self, _, ...)
  local _, subevent, _, source, _, _, dest = ...
  if subevent == "SWING_DAMAGE" or subevent == "SWING_MISSED" then
    if source == "Vengeful Shade" then
      self.explosions[dest] = (self.explosions[dest] or 0) + 1
    end
  end
end)

local function DBMEventHandler(event, mod)
  if mod.id ~= "Deathwhisper" then return end
  if event == "kill" or event == "wipe" then
    local text = GetSpellLink(72010) .. ": "
    local next = next(f.explosions)
    if not next then
      text = text .. "none"
    else
      for name, num in pairs(f.explosions) do
        if name ~= next then
          text = text .. ", "
        end
        text = text .. UnitNameColored(name) .. "(" .. num .. ")"
      end
    end
    RaidEvents:print(text)
    table.wipe(f.explosions)
    f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  elseif event == "pull" then
    table.wipe(f.explosions)
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  end
end

DBM:RegisterCallback("pull", DBMEventHandler)
DBM:RegisterCallback("kill", DBMEventHandler)
DBM:RegisterCallback("wipe", DBMEventHandler)