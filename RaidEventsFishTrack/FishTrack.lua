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
end)