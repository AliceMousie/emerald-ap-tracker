ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
PLAYER_ID = -1
TEAM_NUMBER = 0
--SLOT_DATA = nil

FLAG_CODES = {
    "","","","",
    "defeatnorman",
    "","","",
    "recovergoods",
    "stevenletter",
    "sterngoods",
    "weatherins",
    "stealmeteor",
    "clearmagma",
    "stealsub",
    "clearaqua",
    "spacecenter",
    "releasekyogre",
    "releaserayquaza",
    "stevendive",
    "becomechampion"
}

function has_value (t, val)
    for i, v in ipairs(t) do
        if v == val then return 1 end
    end
    return 0
end

function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end


function onClear(slot_data)
    --SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            end
        end
    end
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                end
            end
        end
    end

    if slot_data == nil  then
        print("its fucked")
        return
    end

    PLAYER_ID = Archipelago.PlayerNumber or -1
    TEAM_NUMBER = Archipelago.TeamNumber or 0

    mapToggle={[0]=0,[1]=1}
    mapToggleReverse={[0]=1,[1]=0}
    mapTripleReverse={[0]=2,[1]=1,[2]=0}
    mapFreeFly={[0]=0,[5]=1,[6]=2,[7]=3,[8]=4,[9]=5,[10]=6,[11]=7,[12]=8,[13]=9,[15]=10}
    mapBadges={}
    for i=0,8 do mapBadges[i]=i end

    slotCodes = {hidden_items={code="op_hid", mapping=mapToggle},
        npc_gifts={code="op_npc", mapping=mapToggle},
        overworld_items={code="op_ovw", mapping=mapToggleReverse},
        rods={code="op_rod", mapping=mapToggle},
        bikes={code="op_bik", mapping=mapToggle},
        key_items={code="op_ki", mapping=mapToggleReverse},
        enable_ferry={code="op_fer", mapping=mapToggle},
        require_flash={code="op_hm5", mapping=mapToggleReverse},
        require_itemfinder={code="op_if", mapping=mapToggleReverse},
        hms={code="op_hms", mapping=mapTripleReverse},
        badges={code="op_bdg", mapping=mapTripleReverse},
        norman_requirement={code="op_norm", mapping=mapToggle},
        elite_four_requirement={code="op_e4", mapping=mapToggle},
        extra_boulders={code="op_es", mapping=mapToggle},
        fly_without_badge={code="op_fwb", mapping=mapToggleReverse},
        free_fly_location_id={code="op_ff", mapping=mapFreeFly},
        norman_count={code="normanreq", mapping=mapBadges},
        elite_four_count={code="e4req", mapping=mapBadges}
    }

    roadblockCodes={["Route 110 Aqua Grunts"]="pass_sp",
        ["Route 112 Magma Grunts"]="pass_cc",
        ["Route 119 Aqua Grunts"]="pass_wi",
        ["Safari Zone Construction Workers"]="pass_sa",
        ["Lilycove City Wailmer"]="pass_wa",
        ["Aqua Hideout Grunts"]="pass_hi",
        ["Seafloor Cavern Aqua Grunt"]="pass_sf"}

    --print(dump_table(slot_data))

    for k,v in pairs(slot_data) do
        if k == "remove_roadblocks" then
            for r,c in pairs(roadblockCodes) do
                Tracker:FindObjectForCode(c).CurrentStage = has_value(slot_data['remove_roadblocks'],r)
            end
        elseif slotCodes[k] then
            Tracker:FindObjectForCode(slotCodes[k].code).CurrentStage = slotCodes[k].mapping[v]
        end
    end

    if PLAYER_ID>-1 then
        updateEvents(0)
        local eventId="pokemon_emerald_events_"..TEAM_NUMBER.."_"..PLAYER_ID
        Archipelago:SetNotify({eventId})
        Archipelago:Get({eventId})
    end
end

function onItem(index, item_id, item_name, player_number)
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local v = ITEM_MAPPING[item_id]
    if not v or not v[1] then
        --print(string.format("onItem: could not find item mapping for id %s", item_id))
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
        end
    else
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
end

--called when a location gets cleared
function onLocation(location_id, location_name)
    local v = LOCATION_MAPPING[location_id]
    if not v or not v[1] then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[1]:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
        else
            obj.Active = true
        end
    else
        print(string.format("onLocation: could not find object for code %s", v[1]))
    end
end

function onEvent(key, value, old_value)
    updateEvents(value)
end

function onEventsLaunch(key, value)
    updateEvents(value)
end

function updateEvents(value)
    if value ~= nil then
        local gyms = 0
        for i, code in ipairs(FLAG_CODES) do
            local bit = value >> (i - 1) & 1
            if i < 9 then
                gyms = gyms + bit
            end
            if #code>0 then
                Tracker:FindObjectForCode(code).Active = bit
            end
        end
        Tracker:FindObjectForCode("gyms").CurrentStage = gyms
    end
end

Archipelago:AddClearHandler("clear handler", onClear)
Archipelago:AddItemHandler("item handler", onItem)
Archipelago:AddLocationHandler("location handler", onLocation)
Archipelago:AddSetReplyHandler("event handler", onEvent)
Archipelago:AddRetrievedHandler("event launch handler", onEventsLaunch)