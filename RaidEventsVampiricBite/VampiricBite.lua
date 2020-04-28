local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(_, _, ...)
  local arg = { ... }
  if arg[2] == "SPELL_CAST_SUCCESS" and table.contains({ 71728, 71729, 71476, 71477, 71727, 71475 }, arg[9]) then
    -- 71728 & 71476 10hc
    -- 71729 & 71477 25hc
    -- 71727 & 71475 25n
    RaidEvents:print(GetSpellLink(arg[9]) .. ": " .. UnitNameColored(arg[4]) .. " -> " .. UnitNameColored(arg[7]))
  end
end)
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")