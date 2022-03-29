local RaidEventsBacklash = CreateFrame("Frame")
RaidEventsBacklash.COMBAT_LOG_DELAY = math.min(select(3, GetNetStats()), 100) * 2 / 1000
RaidEventsBacklash.stacks = {}
RaidEventsBacklash.damage = {}
RaidEventsBacklash.AceTimer = LibStub("AceAddon-3.0"):NewAddon("RaidEventsBacklash", "AceTimer-3.0")
RaidEventsBacklash.timers = {}

function RaidEventsBacklash:reset(player)
  if player then
    self.stacks[player] = nil
    table.wipe(self.damage[player])
    if self.timers[player] then
      self.AceTimer:CancelTimer(self.timers[player])
      self.timers[player] = nil
    end
  else
    table.wipe(self.stacks)
    table.wipe(self.damage)
    self.AceTimer:CancelAllTimers()
    table.wipe(self.timers)
  end
end

function RaidEventsBacklash:formatDamage(damage)
  return floor(damage / 1000 + 0.5) .. "k"
end

function RaidEventsBacklash:report(player)
  local damage_total = 0
  local message = ""
  for name, damage in pairs(self.damage[player]) do
    if UnitIsPlayer(name) then
      damage_total = damage_total + damage
      if message ~= "" then
        message = message .. ", "
      end
      message = message .. UnitNameColored(name) .. "(" .. self:formatDamage(damage) .. ")"
    end
  end
  message = (GetSpellLink(71045) or "Backlash") .. " " .. self:formatDamage(damage_total) .. " " .. UnitNameColored(player) .. "(" .. (self.stacks[player] or "?") .. ") > " .. message
  RaidEvents:print(message)
  self:reset(player)
end

local function DBMEventHandler(event, mod)
  if mod.id ~= "Sindragosa" then
    return
  end
  if event == "kill" or event == "wipe" then
    RaidEventsBacklash:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    RaidEventsBacklash:reset()
  elseif event == "pull" then
    RaidEventsBacklash:reset()
    RaidEventsBacklash:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  end
end

RaidEventsBacklash:SetScript("OnEvent", function(self, _, ...)
  --timestamp, event, sourceguid, sourcename, sourceflags, destguid, destname, destflags, spellid, spellname, spellschool, amount, stacks
  local arg = { ... }
  if arg[2] == "SPELL_AURA_APPLIED" and arg[9] == 69766 then
    -- instability applied (1st stack)
    self.stacks[arg[7]] = 1
  elseif arg[2] == "SPELL_AURA_APPLIED_DOSE" and arg[9] == 69766 then
    -- instability stack gained
    self.stacks[arg[7]] = arg[13]
  elseif table.contains({ 71046, 71045, 71044, 69770 }, arg[9]) then
    -- 69770 10n
    -- 71045 10hc
    -- 71044 25n
    -- 71045 25hc
    -- backlash damage, recording

    if self.timers[arg[4]] then
      -- cancelling old timer
      self.AceTimer:CancelTimer(self.timers[arg[4]])
      self.timers[arg[4]] = nil
    end

    if self.damage[arg[4]] == nil then
      -- initiating damage counter
      self.damage[arg[4]] = {}
    end

    if arg[2] == "SPELL_DAMAGE" then
      self.damage[arg[4]][arg[7]] = arg[12]
    elseif arg[2] == "SPELL_MISSED" then
      self.damage[arg[4]][arg[7]] = 0
    end

    -- registering new timer
    self.timers[arg[4]] = self.AceTimer:ScheduleTimer(function(player)
      self:report(player)
    end, self.COMBAT_LOG_DELAY, arg[4])

  end
end)

DBM:RegisterCallback("pull", DBMEventHandler)
DBM:RegisterCallback("kill", DBMEventHandler)
DBM:RegisterCallback("wipe", DBMEventHandler)