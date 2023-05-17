function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count >= amount
    end
end

function badges()
    return Tracker:ProviderCountForCode("stonebadge") + Tracker:ProviderCountForCode("knucklebadge") + Tracker:ProviderCountForCode("dynamobadge") + Tracker:ProviderCountForCode("heatbadge") + Tracker:ProviderCountForCode("balancebadge") + Tracker:ProviderCountForCode("featherbadge") + Tracker:ProviderCountForCode("rainbadge") + Tracker:ProviderCountForCode("mindbadge")
end

function norman_open()
    if (has("op_norm_bdg")) then
        return badges() >= Tracker:ProviderCountForCode('normanreq')
    end
    return  Tracker:ProviderCountForCode('gyms') >= Tracker:ProviderCountForCode('normanreq')
end

function e4_open()
    if (has("op_e4_bdg")) then
        return badges() >= Tracker:ProviderCountForCode('e4req')
    end
    return Tracker:ProviderCountForCode('gyms') >= Tracker:ProviderCountForCode('e4req')
end

function hid()
    return has("itemfinder") or has("op_if_off")
end

function can_cut()
    return (has("hm01") and has("stonebadge"))
end

function can_flash()
    return (has("op_hm5_off") or (has("hm05") and has("knucklebadge")))
end

function can_rocksmash()
    return (has("hm06") and has("dynamobadge"))
end

function can_strength()
    return (has("hm04") and has("heatbadge"))
end

function can_surf()
    return (has("hm03") and has("balancebadge"))
end

function can_fly()
    return (has("hm02") and (has("featherbadge") or has("op_fwb_on")))
end

function can_dive()
    return (has("hm08") and has("mindbadge") and can_surf())
end

function can_waterfall()
    return (has("hm07") and has("rainbadge") and can_surf())
end

function can_bike()
    return (has("machbike") or has("acrobike"))
end

function can_freefly(id)
    return (can_fly() and has("op_ff_"..id))
end

function ferry_from_slateport()
    return slateport_access() and has("op_fer_on") and has("ssticket")
end

function ferry_from_lilycove()
    return (can_freefly("11") or can_freefly("10")) and has("op_fer_on") and has("ssticket")
end

function dewford_access()
    return (has("recovergoods") or can_surf())
end

function pass_slateport()
    return (has("pass_sp_on") or has("sterngoods") or can_bike())
end

function pass_cablecar()
    return (has("pass_cc_on") or has("stealmeteor"))
end

function pass_weatherins()
    return (has("pass_wi_on") or has("weatherins"))
end

function pass_hideout()
    return (has("pass_hi_on") or has("stealsub"))
end

function pass_wailmers()
    return (can_surf() and (has("pass_wa_on") or has("clearaqua")))
end

function pass_safari()
    return (has("pass_sa_on") or has("becomechampion"))
end

function pass_seafloor()
    return (has("pass_sf_on") or has("spacecenter"))
end

function slateport_access()
    return (can_freefly("5") or has("stevenletter") or can_surf() or ferry_from_lilycove() or ((can_freefly("6") or can_freefly("7") or can_rocksmash()) and pass_slateport()))
end

function mauville_access()
    return (can_freefly("6") or can_freefly("7") or can_rocksmash() or can_surf() or (slateport_access() and pass_slateport()))
end

function fallarbor_access()
    return (can_freefly("8") or can_freefly("9") or (has("stealmeteor")) or (mauville_access() and can_rocksmash()))
end

function meteorfalls_access()
    return ((can_surf() or fallarbor_access()) and (has("op_es_off") or (has("op_es_on") and can_strength())))
end

function lavaridge_access()
    return (can_freefly("9") or (pass_cablecar() and fallarbor_access()))
end

function rt119_south_access()
    return (mauville_access() and can_surf()) or (rt121_access() and pass_weatherins())
end

function fortree_side_access()
    return can_freefly("10") or (mauville_access() and can_surf() and pass_weatherins())
end

function rt121_access()
    return fortree_side_access() or (lilycove_access() and (can_cut() or can_surf()))
end

function fly_to_rt124()
    return can_surf() and (can_freefly("12") or can_freefly("15") or (can_freefly("13") and can_dive()))
end

function lilycove_access()
    return can_freefly("11") or fortree_side_access() or ferry_from_slateport() or (fly_to_rt124() and pass_wailmers())
end

function rt124_access()
    return fly_to_rt124() or (lilycove_access() and can_surf() and pass_wailmers())
end

function mossdeep_access()
    return can_freefly("12") or rt124_access()
end

function sootopolis_access()
    return can_freefly("13") or (rt124_access() and can_dive())
end

function victory_road_access()
    return can_freefly("15") or (rt124_access() and can_waterfall())
end

function elite_four()
    return e4_open() and victory_road_access() and can_waterfall() and can_flash() and can_strength() and can_rocksmash()
end