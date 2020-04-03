local MAJOR, MINOR = "LibUnitNameColored", tonumber("1.0")
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

function UnitNameColored(unit)
  if not unit then
    return
  end
  local class = select(2, UnitClass(unit))
  if not class then
    return unit
  end
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
  return "|cFF"..colors[class]..unit.."|r"
end