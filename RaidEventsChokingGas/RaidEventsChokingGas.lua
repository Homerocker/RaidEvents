local f = CreateFrame("Frame")
f.gas = {}

f:SetScript("OnEvent", function(self, _, ...)
  local arg = { ... }
  if arg[2] == "SPELL_AURA_APPLIED" and table.contains({ 72620, 72460, 71278, 72619 }, arg[9]) then
    -- 72620 25hc
    -- 72460 25n
    --71278 10hc?
    -- 72619 10hc
    self.gas[arg[7]] = (self.gas[arg[7]] or 0) + 1
  end
end)

local function DBMEventHandler(event, mod)
  if mod.id ~= "Putricide" then return end
  if event == "kill" or event == "wipe" then
    local text = GetSpellLink(72620) .. ": "
    local next = next(f.gas)
    if not next then
      text = text .. "none"
    else
      for name, num in pairs(f.gas) do
        if name ~= next then
          text = text .. ", "
        end
        text = text .. UnitNameColored(name) .. "(" .. num .. ")"
      end
    end
    RaidEvents:print(text)
    table.wipe(f.gas)
    f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  elseif event == "pull" then
    table.wipe(f.gas)
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  end
end

DBM:RegisterCallback("pull", DBMEventHandler)
DBM:RegisterCallback("kill", DBMEventHandler)
DBM:RegisterCallback("wipe", DBMEventHandler)