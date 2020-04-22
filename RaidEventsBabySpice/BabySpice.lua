local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
  local arg = {...}
  if arg[9] == 60122 and (arg[2] == "SPELL_AURA_APPLIED" or arg[2] == "SPELL_AURA_REFRESH") then
    RaidEvents:print(arg[4].." applied Baby Spice on "..arg[7])
  end
end)
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")