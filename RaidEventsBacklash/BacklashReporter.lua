local f = CreateFrame("Frame")

f.COMBAT_LOG_DELAY = math.min(select(3, GetNetStats()), 100) * 2 / 1000
f.explosion_players = {}
f.stacks = {}
f.backlash_damaged_players = {}
f.backlash_damaged_pets = {}

function f:reset()
    self.timestamp = nil
    for _, name in pairs(self.explosion_players) do
        self.stacks[name] = nil
    end
    table.wipe(self.explosion_players)
    self.backlash_damage = nil
    table.wipe(self.backlash_damaged_players)
    table.wipe(self.backlash_damaged_pets)
end

function f:formatDamage(damage)
    return (floor(damage / 100 + 0.5) / 10)
end

function f:report()
    if self.backlash_damage == nil then
        if self.explosion_players ~= {} then
            -- no backlash data
            RaidEvents:print("\124cFFFF0000BacklashReporter: Backlash not recorded, dumping Instability data.")
        end
    elseif self.explosion_players == {} then
        -- no instability data
        RaidEvents:print("\124cFFFF0000BacklashReporter: Instability not recorded, dumping Backlash data.")
    else
        local players = 0
        local pets = 0
        for _ in pairs(self.backlash_damaged_players) do
            players = players + 1
        end
        for _ in pairs(self.backlash_damaged_pets) do
            pets = pets + 1
        end
        local text = GetSpellLink(71045) .. ": " .. self:formatDamage(self.backlash_damage) .. "k [" .. players .. " players, " .. pets .. " pets]: "
        for index, name in pairs(self.explosion_players) do
            if self.stacks[name] then
                if index ~= 1 then
                    text = text .. ", "
                end
                text = text .. UnitNameColored(name) .. " (" .. (self.stacks[name]) .. ")"
            end
        end
        RaidEvents:print(text)
    end
    self:reset()
end

f:SetScript("OnEvent", function(self, _, ...)
    --timestamp, event, sourceguid, sourcename, sourceflags, destguid, destname, destflags, spellid, spellname, spellschool, amount, stacks
    local arg = { ... }
    if self.timestamp and (arg[1] - self.timestamp) > self.COMBAT_LOG_DELAY then
        self:report()
    end
    if arg[2] == "SPELL_AURA_APPLIED" and arg[9] == 69766 then
        -- instability applied (1st stack)
        self.stacks[arg[7]] = 1
    elseif arg[2] == "SPELL_AURA_APPLIED_DOSE" and arg[9] == 69766 then
        -- instability stack gained
        self.stacks[arg[7]] = arg[13]
    elseif arg[2] == "SPELL_AURA_REMOVED" and arg[9] == 69766 and self.stacks[arg[7]] then
        -- instability removed
        self.timestamp = arg[1]
        table.insert(self.explosion_players, arg[7])
    elseif table.contains({ 71046, 71045, 71044, 69770 }, arg[9]) then
        -- 69770 10n
        -- 71045 10hc
        -- 71044 25n
        -- 71045 25hc
        -- backlash damage, recording
        if arg[2] == "SPELL_DAMAGE" then
            self.timestamp = arg[1]
            if UnitIsPlayer(arg[7]) then
                self.backlash_damaged_players[arg[6]] = true
            else
                self.backlash_damaged_pets[arg[6]] = true
            end
            self.backlash_damage = (self.backlash_damage or 0) + arg[12]
        elseif arg[2] == "SPELL_MISSED" then
            if self.backlash_damage == nil then
                self.backlash_damage = 0
            end
        end
    end
end)

local function DBMEventHandler(event, mod)
    if mod.id ~= "Sindragosa" then
        return
    end
    if event == "kill" or event == "wipe" then
        LibStub("AceAddon-3.0"):NewAddon("BacklashReporter", "AceTimer-3.0"):ScheduleTimer(function()
            f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            f:report()
        end, math.ceil(f.COMBAT_LOG_DELAY))
    elseif event == "pull" then
        f:reset()
        f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

DBM:RegisterCallback("pull", DBMEventHandler)
DBM:RegisterCallback("kill", DBMEventHandler)
DBM:RegisterCallback("wipe", DBMEventHandler)