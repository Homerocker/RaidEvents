local f = CreateFrame("Frame")
f.mds = {}
f.RagingSpirits = {}
f.ldw = {
  guid = nil,
  phase = 1
}

local function GetClassColor(unit)
  local colors = {
    DEATHKNIGHT = "C41F3B",
    DRUID = "FF7D0A",
    HUNTER = "A9D271",
    MAGE = "40C7EB",
    PALADIN = "F58CBA",
    PRIEST = "FFFFFF",
    ROGUE = "FFF569",
    SHAMAN = "0070DE",
    WARLOCK = "8787ED",
    WARRIOR = "C79C6E"
  }
  if not unit then
    return "FFFFFF"
  end
  return colors[select(2, UnitClass(unit))]
end

f:SetScript("OnEvent", function(self, _, ...)
  local arg = { ... }
  if arg[2] == "SPELL_CAST_SUCCESS" and (arg[9] == 34477 or arg[9] == 57934) and UnitInRaid(arg[4]) then
    -- MD casted
    self.mds[arg[4]] = {}
    self.mds[arg[4]]["target"] = arg[7]
    self.mds[arg[4]]["damage"] = {}
  elseif arg[2] == "SPELL_AURA_APPLIED" then
    if arg[9] == 70842 then
      -- Mana barrier, 1st phase of LDW started
      self.ldw["guid"] = arg[6]
      self.ldw["phase"] = 1
    elseif (arg[9] == 35079 or arg[9] == 59628) and UnitInRaid(arg[4]) then
      -- MD activated
      local target
      if not self.mds[arg[4]] then
        self.mds[arg[4]] = {}
      end
      if self.mds[arg[4]]["target"] then
        target = self.mds[arg[4]]["target"]
      end
      RaidEvents:print("|cFF" .. GetClassColor(arg[4]) .. arg[4] .. "|r triggered MD on |cFF" .. GetClassColor(target) .. (target or "Unknown"))
      self.mds[arg[4]]["mobs"] = {}
      self.mds[arg[4]]["damage"] = {}
    end
  elseif arg[2] == "SPELL_AURA_REMOVED" then
    if arg[9] == 70842 then
      -- Mana Barrier removed, LDW 2nd phase started
      self.ldw["guid"] = arg[6]
      self.ldw["phase"] = 2
    elseif (arg[9] == 35079 or arg[9] == 59628) and UnitInRaid(arg[7]) then
      -- MD effect ended
      local target
      local damage = {}
      if self.mds[arg[7]] then
        if self.mds[arg[7]]["target"] then
          target = self.mds[arg[7]]["target"]
        end
        if self.mds[arg[7]]["damage"] then
          damage = self.mds[arg[7]]["damage"]
        end
      end
      RaidEvents:print("MD |cFF" .. GetClassColor(arg[7]) .. arg[7] .. "|r -> " .. "|cFF" .. GetClassColor(target) .. (target or "Unknown") .. "|r:")
      for k, v in pairs(damage) do
        local damage_done = 0
        for _, v2 in pairs(v) do
          damage_done = damage_done + v2
        end
        if tonumber(k) then
          for k2, v2 in pairs(self.RagingSpirits) do
            if v2["guid"] == k then
              k = v2["name"] .. " #" .. k2
              break
            end
          end
        end
        RaidEvents:print(k .. " - " .. format("%.1f", damage_done / 1000) .. "k")
        --for k2, v2 in pairs(v) do
        --  local k2 = GetSpellLink(k2)
        -- RaidEvents:print(k2 .. " - " .. format("%.1f", v2 / 1000) .. "k")
        --end
      end
      self.mds[arg[7]] = nil
    end
  elseif arg[2] == "SPELL_CAST_START" and table.contains({ 74270, 74271, 74272, 74273, 74274, 74275, 68981, 72259 }, arg[9]) then
    -- Remorseless Winter, resetting Raging Spirit counter
    -- 74270 25n trans1
    -- 74273 25n trans2
    -- 74272 25hc trans1
    -- 74275 25hc trans2
    -- 74274 p2?
    -- 74271 10n trans2
    -- 68981 ?
    -- 72259 p2?
    self.RagingSpirits = {}
  end

  if arg[2] == "SPELL_DAMAGE" or arg[2] == "SWING_DAMAGE" or arg[2] == "RANGE_DAMAGE" then
    if self.mds[arg[4]] and not UnitIsFriend("player", arg[7]) then

      local mob = ((arg[7] == "Raging Spirit" or arg[7] == "Гневный Дух") and arg[6] or arg[7])

      if arg[6] == self.ldw["guid"] then
        -- LDW phase
        mob = mob .. " P" .. self.ldw["phase"]
      end

      if not self.mds[arg[4]]["damage"][mob] then
        -- first damage to the mob under effect of the MD, initializing damage table
        self.mds[arg[4]]["damage"][mob] = {}
      end

      -- calculating damage
      if arg[2] == "SWING_DAMAGE" then
        self.mds[arg[4]]["damage"][mob][6603] = (self.mds[arg[4]]["damage"][mob][6603] or 0) + arg[9]
      elseif arg[2] == "RANGE_DAMAGE" or arg[2] == "SPELL_DAMAGE" then
        self.mds[arg[4]]["damage"][mob][arg[9]] = (self.mds[arg[4]]["damage"][mob][arg[9]] or 0) + arg[12]
      end
    end
    if arg[4] == "Raging Spirit" or arg[4] == "Гневный Дух" or arg[7] == "Raging Spirit" or arg[7] == "Гневный Дух" then
      -- detecting raging spirit
      for _, v in pairs(self.RagingSpirits) do
        if v["guid"] == ((arg[4] == "Raging Spirit" or arg[4] == "Гневный Дух") and arg[3] or arg[6]) then
          -- this Raging Spirit already in table
          return
        end
      end
      -- adding new Raging Spirit GUID to table
      table.insert(self.RagingSpirits, { guid = ((arg[4] == "Raging Spirit" or arg[4] == "Гневный Дух") and arg[3] or arg[6]), name = ((arg[4] == "Raging Spirit" or arg[4] == "Гневный Дух") and arg[4] or arg[7]) })
    end
  end
end)

local function DBMEventHandler(event, mod)
  if mod.id ~= "Deathwhisper" and mod.id ~= "LichKing" and mod.id ~= "Halion" then return end
  if event == "kill" or event == "wipe" then
    f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  elseif event == "pull" then
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  end
end

DBM:RegisterCallback("pull", DBMEventHandler)
DBM:RegisterCallback("kill", DBMEventHandler)
DBM:RegisterCallback("wipe", DBMEventHandler)