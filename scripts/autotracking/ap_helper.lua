function resetItems() 
	for _, v in pairs(ITEM_MAPPING) do
		if v[1] then
			local obj = Tracker:FindObjectForCode(v[1])
			if obj then
				obj.Active = false
			end
		end
	end
end

function resetLocations() 
	for _, v in pairs(LOCATION_MAPPING) do
		if v[1] then
			local obj = Tracker:FindObjectForCode(v[1])
			if obj then
				obj.AvailableChestCount = 1
			end
		end
	end
end

MAP_TOGGLE={[0]=0,[1]=1}
MAP_TOGGLE_REVERSE={[0]=1,[1]=0}
MAP_TRIPLE={[0]=0,[1]=1,[2]=2}
MAP_TRIPLE_REVERSE={[0]=2,[1]=1,[2]=0}
MAP_FREEFLY={[0]=0,[5]=1,[6]=2,[7]=3,[8]=4,[9]=5,[10]=6,[11]=7,[12]=8,[13]=9,[15]=10}
MAP_BADGES={}
for i=0,8 do MAP_BADGES[i]=i end

SLOT_CODES = {
	hidden_items={
		code="op_hid", 
		mapping=MAP_TOGGLE
	},
	npc_gifts={
		code="op_npc", 
		mapping=MAP_TOGGLE
	},
	overworld_items={
		code="op_ovw", 
		mapping=MAP_TOGGLE_REVERSE
	},
	rods={
		code="op_rod", 
		mapping=MAP_TOGGLE
	},
	bikes={
		code="op_bik", 
		mapping=MAP_TOGGLE
	},
	key_items={
		code="op_ki", 
		mapping=MAP_TOGGLE_REVERSE
	},
	enable_ferry={
		code="op_fer", 
		mapping=MAP_TOGGLE
	},
	require_flash={
		code="op_hm5", 
		mapping=MAP_TOGGLE_REVERSE
	},
	require_itemfinder={
		code="op_if", 
		mapping=MAP_TOGGLE_REVERSE
	},
	hms={
		code="op_hms", 
		mapping=MAP_TRIPLE_REVERSE
	},
	badges={
		code="op_bdg", 
		mapping=MAP_TRIPLE_REVERSE
	},
	norman_requirement={
		code="op_norm", 
		mapping=MAP_TOGGLE
	},
	elite_four_requirement={
		code="op_e4", 
		mapping=MAP_TOGGLE
	},
	extra_boulders={
		code="op_es", 
		mapping=MAP_TOGGLE
	},
	fly_without_badge={
		code="op_fwb", 
		mapping=MAP_TOGGLE_REVERSE
	},
	free_fly_location_id={
		code="op_ff", 
		mapping=MAP_FREEFLY
	},
	norman_count={
		code="normanreq", 
		mapping=MAP_BADGES
	},
	elite_four_count={
		code="e4req", 
		mapping=MAP_BADGES
	},
	goal={
		code="goal", 
		mapping=MAP_TRIPLE
	}
}

ROADBLOCK_CODES={
	["Route 110 Aqua Grunts"]="pass_sp",
	["Route 112 Magma Grunts"]="pass_cc",
	["Route 119 Aqua Grunts"]="pass_wi",
	["Safari Zone Construction Workers"]="pass_sa",
	["Lilycove City Wailmer"]="pass_wa",
	["Aqua Hideout Grunts"]="pass_hi",
	["Seafloor Cavern Aqua Grunt"]="pass_sf"
}
