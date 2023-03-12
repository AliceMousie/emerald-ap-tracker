-- use this file to map the AP item ids to your items
-- first value is the code of the target item and the second is the item type (currently only "toggle", "progressive" and "consumable" but feel free to expand for your needs!)
-- here are the SM items as an example: https://github.com/Cyb3RGER/sm_ap_tracker/blob/main/scripts/autotracking/item_mapping.lua
ITEM_MAPPING = {
    [00000] = {"toggle", "toggle"},
    [00001] = {"progressive", "progressive"},
    [00002] = {"consumable", "consumable"},
    [00003] = {"progressive_toggle", "progressive"} -- progressive_toggle should work with the progressive type but might need additional code to work for your needs
}