local f = CreateFrame("Frame")
f.goo = {}

f:SetScript("OnEvent", function(self, _, ...)
  local arg = { ... }
  if arg[2] == "SPELL_AURA_APPLIED" and (arg[9] == 72550 or arg[9] == 72873 or arg[9] == 72458) then
    -- 72550 25hc
    -- 72873 10hc
    -- 72458 25n
    self.goo[arg[7]] = (self.goo[arg[7]] or 0) + 1
  end
end)

local function DBMEventHandler(event, mod)
  if mod.id ~= "Festergut" and mod.id ~= "Putricide" then return end
  if event == "kill" or event == "wipe" then
    local text = GetSpellLink(72550) .. ": "
    local next = next(f.goo)
    if not next then
      text = text .. "none"
    else
      for name, num in pairs(f.goo) do
        if name ~= next then
          text = text .. ", "
        end
        text = text .. UnitNameColored(name) .. "(" .. num .. ")"
      end
    end
    RaidEvents:print(text)
    table.wipe(f.goo)
    f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  elseif event == "pull" then
    table.wipe(f.goo)
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  end
end

DBM:RegisterCallback("pull", DBMEventHandler)
DBM:RegisterCallback("kill", DBMEventHandler)
DBM:RegisterCallback("wipe", DBMEventHandler)