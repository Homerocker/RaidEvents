local f = CreateFrame("Frame");
f.COMBAT_LOG_DELAY = 150 -- MS

function f:reset()
  self.explosion_timestamp = nil
  if not self.explosion_players then
    self.stacks = {}
    self.explosion_players = {}
  else
    for _, name in pairs(self.explosion_players) do
      self.stacks[name] = nil
    end
    table.wipe(self.explosion_players)
  end
  self.backlash_damage = 0
  self.backlash_damaged_players = 0
  self.backlash_damaged_pets = 0
end

f:reset()

function f:formatDamage(damage)
  return (floor(damage / 100 + 0.5) / 10)
end

function f:report()
  if self.backlash_damage == 0 then
    return
  end
  local text = GetSpellLink(71045) .. ": " .. self:formatDamage(self.backlash_damage) .. "k [" .. self.backlash_damaged_players .. " players, " .. self.backlash_damaged_pets .. " pets]: "
  for index, name in pairs(self.explosion_players) do
    if self.stacks[name] then
      if index ~= 1 then
        text = text .. ", "
      end
      text = text .. UnitNameColored(name) .. " (" .. (self.stacks[name]) .. ")"
    end
  end
  self:reset()
  RaidEvents:print(text)
end

f:SetScript("OnEvent", function(self, event, ...)
  --timestamp, event, sourceguid, sourcename, sourceflags, destguid, destname, destflags, spellid, spellname, spellschool, amount, stacks
  local arg = { ... }
  if self.explosion_timestamp and (arg[1] - self.explosion_timestamp) > (self.COMBAT_LOG_DELAY / 1000) then
    self:report()
  end
  if arg[2] == "SPELL_AURA_APPLIED" and arg[9] == 69766 then
    -- instability applied (1st stack)
    self.stacks[arg[7]] = 1
  elseif arg[2] == "SPELL_AURA_APPLIED_DOSE" and arg[9] == 69766 then
    -- recording instability stacks
    self.stacks[arg[7]] = arg[13]
  elseif arg[2] == "SPELL_AURA_REMOVED" and arg[9] == 69766 and self.stacks[arg[7]] then
    -- instability removed, should start recording backlash data
    self.explosion_timestamp = arg[1]
    table.insert(self.explosion_players, arg[7])
  elseif arg[2] == "SPELL_DAMAGE" and table.contains({ 71046, 71045 }, arg[9]) then
    -- 69770 10n
    -- 71045 10hc
    -- 71044 25n
    -- 71045 25hc
    -- backlash damage, recording
    if not self.explosion_timestamp then
      -- did not detect Instability prior to Backlash, should increase combat log delay?
      RaidEvents:print("\124cFFFF0000BacklashReporter: Instability not recorded, dumping Backlash data. Report this to Homerocker.")
    else
      if UnitIsPlayer(arg[7]) then
        self.backlash_damaged_players = self.backlash_damaged_players + 1
      else
        self.backlash_damaged_pets = self.backlash_damaged_pets + 1
      end
      self.backlash_damage = self.backlash_damage + arg[12]
    end
  elseif arg[2] == "SPELL_CAST_SUCCESS" and table.contains({ 45438, 642 }, arg[9]) then
    -- abilities that remove instability stacks without exploding
    -- 45438 Ice Block
    -- 642 Divine Shield
    self.stacks[arg[4]] = nil
  end
end)
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")