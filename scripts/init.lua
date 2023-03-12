Tracker:AddItems("items/items.json")
-- Logic
ScriptHost:LoadScript("scripts/logic/logic.lua")

if not IS_ITEMS_ONLY then
    -- Maps
    Tracker:AddMaps("maps/maps.json")    
    -- Locations
    Tracker:AddLocations("locations/locations.json")
end

-- Layout
Tracker:AddLayouts("layouts/events.json")
Tracker:AddLayouts("layouts/settings.json")
Tracker:AddLayouts("layouts/items.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" and 0 then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end
