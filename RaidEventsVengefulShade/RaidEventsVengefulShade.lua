local f = CreateFrame("Frame")
f.shades = {}
f.explosions = {}

f:SetScript("OnEvent", function(self, _, ...)
  local arg = { ... }
  if arg[2] == "SPELL_SUMMON" and arg[9] == 71426 then
    -- Vengeful Shade summoned
    -- 71426 25n/25hc/10hc
    table.insert(self.shades, arg[6])
  elseif arg[2] == "SWING_DAMAGE" or arg[2] == "SWING_MISSED" then
    for _, v in pairs(self.shades) do
      if v == arg[3] then
        self.explosions[arg[7]] = (self.explosions[arg[7]] or 0) + 1
      end
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
    table.wipe(f.shades)
    table.wipe(f.explosions)
    f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  elseif event == "pull" then
    table.wipe(f.shades)
    table.wipe(f.explosions)
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  end
end

DBM:RegisterCallback("pull", DBMEventHandler)
DBM:RegisterCallback("kill", DBMEventHandler)
DBM:RegisterCallback("wipe", DBMEventHandler)