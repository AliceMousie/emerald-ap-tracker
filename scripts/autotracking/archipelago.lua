-- this is an example/ default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via thier ids
-- it will also load the AP slot data in the global SLOT_DATA, keep track of the current index of on_item messages in CUR_INDEX
-- addition it will keep track of what items are local items and which one are remote using the globals LOCAL_ITEMS and GLOBAL_ITEMS
-- this is useful since remote items will not reset but local items might
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

EVENT_FLAGS = {"FLAG_RECEIVED_POKENAV",
"FLAG_DELIVERED_STEVEN_LETTER",
"FLAG_DELIVERED_DEVON_GOODS",
"FLAG_HIDE_ROUTE_119_TEAM_AQUA",
"FLAG_MET_ARCHIE_METEOR_FALLS",
"FLAG_GROUDON_AWAKENED_MAGMA_HIDEOUT",
"FLAG_MET_TEAM_AQUA_HARBOR",
"FLAG_TEAM_AQUA_ESCAPED_IN_SUBMARINE",
"FLAG_DEFEATED_MAGMA_SPACE_CENTER",
"FLAG_KYOGRE_ESCAPED_SEAFLOOR_CAVERN",
"FLAG_HIDE_SKY_PILLAR_TOP_RAYQUAZA",
"FLAG_OMIT_DIVE_FROM_STEVEN_LETTER",
"FLAG_IS_CHAMPION",
"FLAG_DEFEATED_RUSTBORO_GYM",
"FLAG_DEFEATED_DEWFORD_GYM",
"FLAG_DEFEATED_MAUVILLE_GYM",
"FLAG_DEFEATED_LAVARIDGE_GYM",
"FLAG_DEFEATED_PETALBURG_GYM",
"FLAG_DEFEATED_FORTREE_GYM",
"FLAG_DEFEATED_MOSSDEEP_GYM",
"FLAG_DEFEATED_SOOTOPOLIS_GYM"}

TRACKED_EVENTS = {FLAG_RECEIVED_POKENAV=0,
FLAG_DELIVERED_STEVEN_LETTER=0,
FLAG_DELIVERED_DEVON_GOODS=0,
FLAG_HIDE_ROUTE_119_TEAM_AQUA=0,
FLAG_MET_ARCHIE_METEOR_FALLS=0,
FLAG_GROUDON_AWAKENED_MAGMA_HIDEOUT=0,
FLAG_MET_TEAM_AQUA_HARBOR=0,
FLAG_TEAM_AQUA_ESCAPED_IN_SUBMARINE=0,
FLAG_DEFEATED_MAGMA_SPACE_CENTER=0,
FLAG_KYOGRE_ESCAPED_SEAFLOOR_CAVERN=0,
FLAG_HIDE_SKY_PILLAR_TOP_RAYQUAZA=0,
FLAG_OMIT_DIVE_FROM_STEVEN_LETTER=0,
FLAG_IS_CHAMPION=0,
FLAG_DEFEATED_RUSTBORO_GYM=0,
FLAG_DEFEATED_DEWFORD_GYM=0,
FLAG_DEFEATED_MAUVILLE_GYM=0,
FLAG_DEFEATED_LAVARIDGE_GYM=0,
FLAG_DEFEATED_PETALBURG_GYM=0,
FLAG_DEFEATED_FORTREE_GYM=0,
FLAG_DEFEATED_MOSSDEEP_GYM=0,
FLAG_DEFEATED_SOOTOPOLIS_GYM=0}

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return 1
        end
    end

    return 0
end


function onClear(slot_data)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        --print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", v[1], v[2]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}

    Archipelago:SetNotify(EVENT_FLAGS)
    Archipelago:Get(EVENT_FLAGS)

    if SLOT_DATA == nil  then
        print("its fucked")
        return
    end

    if slot_data['hidden_items'] then
        local obj = Tracker:FindObjectForCode("op_hid")
        if obj then
            obj.CurrentStage = 1 - slot_data['hidden_items']
        end --default is 0 is on, so invert
    end

    if slot_data['npc_gifts'] then
        local obj = Tracker:FindObjectForCode("op_npc")
        if obj then
            obj.CurrentStage = 1 - slot_data['npc_gifts']
        end
    end

    if slot_data['overworld_items'] then
        local obj = Tracker:FindObjectForCode("op_ovw")
        if obj then
            obj.CurrentStage = 1 - slot_data['overworld_items']
        end
    end

    if slot_data['rods'] then
        local obj = Tracker:FindObjectForCode("op_rod")
        if obj then
            obj.CurrentStage = 1 - slot_data['rods']
        end
    end

    if slot_data['bikes'] then
        local obj = Tracker:FindObjectForCode("op_bik")
        if obj then
            obj.CurrentStage = 1 - slot_data['bikes']
        end
    end

    if slot_data['key_items'] then
        local obj = Tracker:FindObjectForCode("op_ki")
        if obj then
            obj.CurrentStage = 1 - slot_data['key_items']
        end
    end

    if slot_data['enable_ferry'] then
        local obj = Tracker:FindObjectForCode("op_fer")
        if obj then
            obj.CurrentStage = 1 - slot_data['enable_ferry']
        end
    end

    if slot_data['require_flash'] then
        local obj = Tracker:FindObjectForCode("op_hm5")
        if obj then
            obj.CurrentStage = 1 - slot_data['require_flash']
        end
    end

    if slot_data['require_itemfinder'] then
        local obj = Tracker:FindObjectForCode("op_if")
        if obj then
            obj.CurrentStage = slot_data['require_itemfinder']
        end
    end

    if slot_data['hms'] then
        local obj = Tracker:FindObjectForCode("op_hms")
        if obj then
            obj.CurrentStage = 2 - slot_data['hms']
        end
    end

    if slot_data['badges'] then
        local obj = Tracker:FindObjectForCode("op_bdg")
        if obj then
            obj.CurrentStage = 2 - slot_data['badges']
        end
    end

    if slot_data['norman_requirement'] then
        local obj = Tracker:FindObjectForCode("op_norm")
        if obj then
            obj.CurrentStage = 1 - slot_data['norman_requirement']
        end
    end

    if slot_data['norman_count'] then
        local obj = Tracker:FindObjectForCode("normanreq")
        if obj then
            obj.AcquiredCount = slot_data['norman_count']
        end
    end

    if slot_data['elite_four_requirement'] then
        local obj = Tracker:FindObjectForCode("op_e4")
        if obj then
            obj.CurrentStage = 1 - slot_data['elite_four_requirement']
        end
    end

    if slot_data['elite_four_count'] then
        local obj = Tracker:FindObjectForCode("e4req")
        if obj then
            obj.AcquiredCount = slot_data['elite_four_count']
        end
    end

    if slot_data['extra_boulders'] then
        local obj = Tracker:FindObjectForCode("op_es")
        if obj then
            obj.CurrentStage = slot_data['extra_boulders']
        end
    end

    if slot_data['fly_without_badge'] then
        local obj = Tracker:FindObjectForCode("op_fwb")
        if obj then
            obj.CurrentStage = slot_data['fly_without_badge']
        end
    end

    if slot_data['free_fly_location_id'] then
        local locs = {[0]=0,[5]=1,[6]=2,[7]=3,[8]=4,[9]=5,[10]=6,[11]=7,[12]=8,[13]=9,[15]=10}
        -- lua is the worst fucking programming language i have ever used. 
        -- this could just be an indexOf on a 0-based array if it had either of those "luxuries"
        local obj = Tracker:FindObjectForCode("op_ff")
        if obj then
            obj.CurrentStage = locs[slot_data['free_fly_location_id']]
        end
    end

    if slot_data['remove_roadblocks'] then
        local obj_sp = Tracker:FindObjectForCode("pass_sp")
        local obj_cc = Tracker:FindObjectForCode("pass_cc")
        local obj_wi = Tracker:FindObjectForCode("pass_wi")
        local obj_hi = Tracker:FindObjectForCode("pass_hi")
        local obj_wa = Tracker:FindObjectForCode("pass_wa")
        local obj_sa = Tracker:FindObjectForCode("pass_sa")
        local obj_sf = Tracker:FindObjectForCode("pass_sf")
        obj_sp.CurrentStage = has_value(slot_data['remove_roadblocks'],"Route 110 Aqua Grunts")
        obj_cc.CurrentStage = has_value(slot_data['remove_roadblocks'],"Route 112 Magma Grunts")
        obj_wi.CurrentStage = has_value(slot_data['remove_roadblocks'],"Route 119 Aqua Grunts")
        obj_sa.CurrentStage = has_value(slot_data['remove_roadblocks'],"Safari Zone Construction Workers")
        obj_wa.CurrentStage = has_value(slot_data['remove_roadblocks'],"Lilycove City Wailmer")
        obj_hi.CurrentStage = has_value(slot_data['remove_roadblocks'],"Aqua Hideout Grunts")
        obj_sf.CurrentStage = has_value(slot_data['remove_roadblocks'],"Seafloor Cavern Aqua Grunt")
    end
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local v = ITEM_MAPPING[item_id]
    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s, type %s", v[1], v[2]))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
    -- track local items via snes interface
    if is_local then
        if LOCAL_ITEMS[v[1]] then
            LOCAL_ITEMS[v[1]] = LOCAL_ITEMS[v[1]] + 1
        else
            LOCAL_ITEMS[v[1]] = 1
        end
    else
        if GLOBAL_ITEMS[v[1]] then
            GLOBAL_ITEMS[v[1]] = GLOBAL_ITEMS[v[1]] + 1
        else
            GLOBAL_ITEMS[v[1]] = 1
        end
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end
end

--called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    local v = LOCATION_MAPPING[location_id]
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[1]:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
        else
            obj.Active = true
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v[1]))
    end
end

function onEvent(key, value, old_value)
    print("-----onEvent-----")
    if value ~= nil then
        print("KEY "..key.." CHANGED TO "..value)
        TRACKED_EVENTS[key] = value
        updateEvents()
    else 
        print ("KEY "..key..": null")
    end
end

function onEventsLaunch(key, value)
    print("-----onEventsLaunch-----")
    if value ~= nil then
        print("KEY "..key.." CHANGED TO "..value)
        TRACKED_EVENTS[key] = value
        updateEvents()
    else 
        print ("KEY "..key..": null")
    end
end

function updateEvents()
    local gyms = TRACKED_EVENTS.FLAG_DEFEATED_RUSTBORO_GYM + TRACKED_EVENTS.FLAG_DEFEATED_DEWFORD_GYM + TRACKED_EVENTS.FLAG_DEFEATED_MAUVILLE_GYM + TRACKED_EVENTS.FLAG_DEFEATED_LAVARIDGE_GYM + TRACKED_EVENTS.FLAG_DEFEATED_PETALBURG_GYM + TRACKED_EVENTS.FLAG_DEFEATED_FORTREE_GYM + TRACKED_EVENTS.FLAG_DEFEATED_SOOTOPOLIS_GYM + TRACKED_EVENTS.FLAG_DEFEATED_MOSSDEEP_GYM 
    Tracker:FindObjectForCode("gyms").AcquiredCount = gyms
    Tracker:FindObjectForCode("recovergoods").Active = TRACKED_EVENTS.FLAG_RECEIVED_POKENAV
    Tracker:FindObjectForCode("stevenletter").Active = TRACKED_EVENTS.FLAG_DELIVERED_STEVEN_LETTER
    Tracker:FindObjectForCode("sterngoods").Active = TRACKED_EVENTS.FLAG_DELIVERED_DEVON_GOODS
    Tracker:FindObjectForCode("stealmeteor").Active = TRACKED_EVENTS.FLAG_MET_ARCHIE_METEOR_FALLS
    Tracker:FindObjectForCode("weatherins").Active = TRACKED_EVENTS.FLAG_HIDE_ROUTE_119_TEAM_AQUA
    Tracker:FindObjectForCode("clearmagma").Active = TRACKED_EVENTS.FLAG_GROUDON_AWAKENED_MAGMA_HIDEOUT
    Tracker:FindObjectForCode("stealsub").Active = TRACKED_EVENTS.FLAG_MET_TEAM_AQUA_HARBOR
    Tracker:FindObjectForCode("clearaqua").Active = TRACKED_EVENTS.FLAG_TEAM_AQUA_ESCAPED_IN_SUBMARINE
    Tracker:FindObjectForCode("spacecenter").Active = TRACKED_EVENTS.FLAG_DEFEATED_MAGMA_SPACE_CENTER
    Tracker:FindObjectForCode("releasekyogre").Active = TRACKED_EVENTS.FLAG_KYOGRE_ESCAPED_SEAFLOOR_CAVERN
    Tracker:FindObjectForCode("releaserayquaza").Active = TRACKED_EVENTS.FLAG_HIDE_SKY_PILLAR_TOP_RAYQUAZA
    Tracker:FindObjectForCode("defeatnorman").Active = TRACKED_EVENTS.FLAG_DEFEATED_PETALBURG_GYM
    Tracker:FindObjectForCode("becomechampion").Active = TRACKED_EVENTS.FLAG_IS_CHAMPION
end

Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
Archipelago:AddSetReplyHandler("event handler", onEvent)
Archipelago:AddRetrievedHandler("event launch handler", onEventsLaunch)