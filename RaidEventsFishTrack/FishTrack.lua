local fishtrack = CreateFrame("Frame")
fishtrack:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
fishtrack.num = {}
fishtrack:SetScript("OnEvent", function(self, event, ...)
    local arg = {...}
    if arg[2] == "SPELL_AURA_REFRESH" and arg[9] == 57073 then
        local name = arg[7]
        if UnitExists(name) --[[e.g. is in raid or party--]] then
            self.num[name] = (self.num[name] or 0) + 1
            if self.num[name] >= 5 then
                RaidEvents:print(name.." has refreshed his Drink buff "..self.num[name].." times!")
            end
        end
    end
    if arg[2] == "SPELL_CREATE" and arg[9] == 57426 then
        table.wipe(self.num)
    end
    if (arg[2] == "SPELL_AURA_APPLIED" or arg[2] == "SPELL_AURA_REFRESH") and arg[9] == 60122 then
      RaidEvents:print(arg[4].." applied Baby Spice on "..arg[7])
    end
	if arg[7] == "Glitched Snowman" and arg[14] ~= nil and table.contains({16, 17, 18, 20, 24, 48, 80, 28, 124, 126, 127}, arg[14]) then
      RaidEvents:print(arg[4].." used "..arg[10]..(UnitInRaid("unit") and "" or " (not in our raid)"))
    end	  
end)