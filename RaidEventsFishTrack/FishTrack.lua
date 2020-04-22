local fishtrack = CreateFrame("Frame")
fishtrack:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
fishtrack.num = {}
fishtrack:SetScript("OnEvent", function(self, event, ...)
    local arg = {...}
    if arg[9] == 57073 and arg[2] == "SPELL_AURA_REFRESH" then
        if UnitExists(arg[7]) --[[e.g. is in raid or party--]] then
            self.num[arg[7]] = (self.num[arg[7]] or 0) + 1
            if self.num[arg[7]] >= 5 then
                RaidEvents:print(arg[7].." has refreshed his Drink buff "..self.num[arg[7]].." times!")
            end
        end
    elseif arg[9] == 57426 and arg[2] == "SPELL_CREATE" then
        table.wipe(self.num)
    end
end)