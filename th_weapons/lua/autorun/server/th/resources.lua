-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

--------------------------------------------------------------------

-- Spawn icons

--------------------------------------------------------------------

resource.AddFile('materials/entities/ent_ammo_hl1_buckshot.png')
resource.AddFile('materials/entities/ent_ammo_hl1_crossbow.png')
resource.AddFile('materials/entities/ent_ammo_hl1_m203.png')
resource.AddFile('materials/entities/ent_ammo_hl1_mp5.png')
resource.AddFile('materials/entities/ent_ammo_hl1_python.png')
resource.AddFile('materials/entities/ent_ammo_th_ap9.png')
resource.AddFile('materials/entities/ent_ammo_th_gas.png')
resource.AddFile('materials/entities/ent_ammo_th_glock.png')
resource.AddFile('materials/entities/ent_ammo_th_sawgas.png')
resource.AddFile('materials/entities/ent_ammo_th_sniper.png')
resource.AddFile('materials/entities/ent_ammo_th_taurus.png')
resource.AddFile('materials/entities/ent_weapon_th_357.png')
resource.AddFile('materials/entities/ent_weapon_th_ap9.png')
resource.AddFile('materials/entities/ent_weapon_th_chaingun.png')
resource.AddFile('materials/entities/ent_weapon_th_chainsaw.png')
resource.AddFile('materials/entities/ent_weapon_th_crossbow.png')
resource.AddFile('materials/entities/ent_weapon_th_einar1.png')
resource.AddFile('materials/entities/ent_weapon_th_flamethrower.png')
resource.AddFile('materials/entities/ent_weapon_th_glock.png')
resource.AddFile('materials/entities/ent_weapon_th_medkit.png')
resource.AddFile('materials/entities/ent_weapon_th_mp5.png')
resource.AddFile('materials/entities/ent_weapon_th_satchel.png')
resource.AddFile('materials/entities/ent_weapon_th_shotgun.png')
resource.AddFile('materials/entities/ent_weapon_th_shovel.png')
resource.AddFile('materials/entities/ent_weapon_th_sniper.png')
resource.AddFile('materials/entities/ent_weapon_th_spanner.png')
resource.AddFile('materials/entities/ent_weapon_th_taurus.png')
resource.AddFile('materials/entities/ent_weapon_th_tnt.png')
resource.AddFile('materials/entities/ent_weapon_th_tripmine.png')
resource.AddFile('materials/entities/ent_weapon_th_umbrella.png')
resource.AddFile('materials/entities/weapon_th_357.png')
resource.AddFile('materials/entities/weapon_th_ap9.png')
resource.AddFile('materials/entities/weapon_th_chaingun.png')
resource.AddFile('materials/entities/weapon_th_chainsaw.png')
resource.AddFile('materials/entities/weapon_th_crossbow.png')
resource.AddFile('materials/entities/weapon_th_einar1.png')
resource.AddFile('materials/entities/weapon_th_flamethrower.png')
resource.AddFile('materials/entities/weapon_th_glock.png')
resource.AddFile('materials/entities/weapon_th_medkit.png')
resource.AddFile('materials/entities/weapon_th_mp5.png')
resource.AddFile('materials/entities/weapon_th_satchel.png')
resource.AddFile('materials/entities/weapon_th_shotgun.png')
resource.AddFile('materials/entities/weapon_th_shovel.png')
resource.AddFile('materials/entities/weapon_th_sniper.png')
resource.AddFile('materials/entities/weapon_th_spanner.png')
resource.AddFile('materials/entities/weapon_th_taurus.png')
resource.AddFile('materials/entities/weapon_th_tnt.png')
resource.AddFile('materials/entities/weapon_th_tripmine.png')
resource.AddFile('materials/entities/weapon_th_umbrella.png')

--------------------------------------------------------------------

-- Materials

--------------------------------------------------------------------

--
-- View models
--

resource.AddFile('materials/models/th/backpack/BPack1.vtf')
resource.AddFile('materials/models/th/backpack/BPack1.vmt')
resource.AddFile('materials/models/th/v_9mmar/BX_Chrome1.vtf')
resource.AddFile('materials/models/th/v_9mmar/BX_Chrome1.vmt')
resource.AddFile('materials/models/th/v_9mmar/gunsidemap.vtf')
resource.AddFile('materials/models/th/v_9mmar/gunsidemap.vmt')
resource.AddFile('materials/models/th/v_9mmar/handleback.vtf')
resource.AddFile('materials/models/th/v_9mmar/handleback.vmt')
resource.AddFile('materials/models/th/v_9mmar/hkmsg90.vtf')
resource.AddFile('materials/models/th/v_9mmar/hkmsg90.vmt')
resource.AddFile('materials/models/th/v_9mmar/scope_chrome.vtf')
resource.AddFile('materials/models/th/v_9mmar/scope_chrome.vmt')
resource.AddFile('materials/models/th/v_9mmhandgun/back.vtf')
resource.AddFile('materials/models/th/v_9mmhandgun/back.vmt')
resource.AddFile('materials/models/th/v_9mmhandgun/bulletCHROME.vtf')
resource.AddFile('materials/models/th/v_9mmhandgun/bulletCHROME.vmt')
resource.AddFile('materials/models/th/v_9mmhandgun/chrome.vtf')
resource.AddFile('materials/models/th/v_9mmhandgun/chrome.vmt')
resource.AddFile('materials/models/th/v_9mmhandgun/gclip.vtf')
resource.AddFile('materials/models/th/v_9mmhandgun/gclip.vmt')
resource.AddFile('materials/models/th/v_9mmhandgun/gclipinside.vtf')
resource.AddFile('materials/models/th/v_9mmhandgun/gclipinside.vmt')
resource.AddFile('materials/models/th/v_9mmhandgun/side.vtf')
resource.AddFile('materials/models/th/v_9mmhandgun/side.vmt')
resource.AddFile('materials/models/th/v_9mmhandgun/top.vtf')
resource.AddFile('materials/models/th/v_9mmhandgun/top.vmt')
resource.AddFile('materials/models/th/v_ap9/tec9.vtf')
resource.AddFile('materials/models/th/v_ap9/tec9.vmt')
resource.AddFile('materials/models/th/v_chainsaw/blade.vtf')
resource.AddFile('materials/models/th/v_chainsaw/blade.vmt')
resource.AddFile('materials/models/th/v_chainsaw/guard.vtf')
resource.AddFile('materials/models/th/v_chainsaw/guard.vmt')
resource.AddFile('materials/models/th/v_chainsaw/handle.vtf')
resource.AddFile('materials/models/th/v_chainsaw/handle.vmt')
resource.AddFile('materials/models/th/v_chainsaw/motor.vtf')
resource.AddFile('materials/models/th/v_chainsaw/motor.vmt')
resource.AddFile('materials/models/th/v_chainsaw/string.vtf')
resource.AddFile('materials/models/th/v_chainsaw/string.vmt')
resource.AddFile('materials/models/th/v_crowbar/Chrome1.vtf')
resource.AddFile('materials/models/th/v_crowbar/Chrome1.vmt')
resource.AddFile('materials/models/th/v_crowbar/Chrome2(Brass).vtf')
resource.AddFile('materials/models/th/v_crowbar/Chrome2(Brass).vmt')
resource.AddFile('materials/models/th/v_crowbar/Umbrella_Base1.vtf')
resource.AddFile('materials/models/th/v_crowbar/Umbrella_Base1.vmt')
resource.AddFile('materials/models/th/v_egon/collarsides_work.vtf')
resource.AddFile('materials/models/th/v_egon/collarsides_work.vmt')
resource.AddFile('materials/models/th/v_egon/handle.vtf')
resource.AddFile('materials/models/th/v_egon/handle.vmt')
resource.AddFile('materials/models/th/v_egon/nm_farm11.vtf')
resource.AddFile('materials/models/th/v_egon/nm_farm11.vmt')
resource.AddFile('materials/models/th/v_egon/nm_farm12.vtf')
resource.AddFile('materials/models/th/v_egon/nm_farm12.vmt')
resource.AddFile('materials/models/th/v_egon/nm_farm14.vtf')
resource.AddFile('materials/models/th/v_egon/nm_farm14.vmt')
resource.AddFile('materials/models/th/v_egon/ring_attach_work.vtf')
resource.AddFile('materials/models/th/v_egon/ring_attach_work.vmt')
resource.AddFile('materials/models/th/v_hands/DM_base.vtf')
resource.AddFile('materials/models/th/v_hands/DM_base.vmt')
resource.AddFile('materials/models/th/v_hands/GLOVE_handpak.vtf')
resource.AddFile('materials/models/th/v_hands/GLOVE_handpak.vmt')
resource.AddFile('materials/models/th/v_hands/GLOVED_knuckle.vtf')
resource.AddFile('materials/models/th/v_hands/GLOVED_knuckle.vmt')
resource.AddFile('materials/models/th/v_hands/GLOVED_sleeve.vtf')
resource.AddFile('materials/models/th/v_hands/GLOVED_sleeve.vmt')
resource.AddFile('materials/models/th/v_hands/hand.vtf')
resource.AddFile('materials/models/th/v_hands/hand.vmt')
resource.AddFile('materials/models/th/v_hands/HAND_ForeArm1.vtf')
resource.AddFile('materials/models/th/v_hands/HAND_ForeArm1.vmt')
resource.AddFile('materials/models/th/v_hands/PLAYER_ForeArm1.vtf')
resource.AddFile('materials/models/th/v_hands/PLAYER_ForeArm1.vmt')
resource.AddFile('materials/models/th/v_hands/thumb.vtf')
resource.AddFile('materials/models/th/v_hands/thumb.vmt')
resource.AddFile('materials/models/th/v_hands/xbow_sleeve.vtf')
resource.AddFile('materials/models/th/v_hands/xbow_sleeve.vmt')
resource.AddFile('materials/models/th/v_hkg36/barrel.vtf')
resource.AddFile('materials/models/th/v_hkg36/barrel.vmt')
resource.AddFile('materials/models/th/v_hkg36/buttstock.vtf')
resource.AddFile('materials/models/th/v_hkg36/buttstock.vmt')
resource.AddFile('materials/models/th/v_hkg36/forearm.vtf')
resource.AddFile('materials/models/th/v_hkg36/forearm.vmt')
resource.AddFile('materials/models/th/v_hkg36/handle.vtf')
resource.AddFile('materials/models/th/v_hkg36/handle.vmt')
resource.AddFile('materials/models/th/v_hkg36/lower_body.vtf')
resource.AddFile('materials/models/th/v_hkg36/lower_body.vmt')
resource.AddFile('materials/models/th/v_hkg36/lower_body_part2.vtf')
resource.AddFile('materials/models/th/v_hkg36/lower_body_part2.vmt')
resource.AddFile('materials/models/th/v_hkg36/magazine.vtf')
resource.AddFile('materials/models/th/v_hkg36/magazine.vmt')
resource.AddFile('materials/models/th/v_hkg36/misc.vtf')
resource.AddFile('materials/models/th/v_hkg36/misc.vmt')
resource.AddFile('materials/models/th/v_hkg36/scope.vtf')
resource.AddFile('materials/models/th/v_hkg36/scope.vmt')
resource.AddFile('materials/models/th/v_shotgun/barrel_chrome.vtf')
resource.AddFile('materials/models/th/v_shotgun/barrel_chrome.vmt')
resource.AddFile('materials/models/th/v_shotgun/barrelltop.vtf')
resource.AddFile('materials/models/th/v_shotgun/barrelltop.vmt')
resource.AddFile('materials/models/th/v_shotgun/bodyback.vtf')
resource.AddFile('materials/models/th/v_shotgun/bodyback.vmt')
resource.AddFile('materials/models/th/v_shotgun/grip.vtf')
resource.AddFile('materials/models/th/v_shotgun/grip.vmt')
resource.AddFile('materials/models/th/v_shotgun/handle.vtf')
resource.AddFile('materials/models/th/v_shotgun/handle.vmt')
resource.AddFile('materials/models/th/v_shotgun/shell.vtf')
resource.AddFile('materials/models/th/v_shotgun/shell.vmt')
resource.AddFile('materials/models/th/v_shotgun/sidemap.vtf')
resource.AddFile('materials/models/th/v_shotgun/sidemap.vmt')
resource.AddFile('materials/models/th/v_shotgun/sight.vtf')
resource.AddFile('materials/models/th/v_shotgun/sight.vmt')
resource.AddFile('materials/models/th/v_shovel/-0silo2_pan2.vtf')
resource.AddFile('materials/models/th/v_shovel/-0silo2_pan2.vmt')
resource.AddFile('materials/models/th/v_shovel/wood.vtf')
resource.AddFile('materials/models/th/v_shovel/wood.vmt')
resource.AddFile('materials/models/th/v_taurus/body.vtf')
resource.AddFile('materials/models/th/v_taurus/body.vmt')
resource.AddFile('materials/models/th/v_taurus/side.vtf')
resource.AddFile('materials/models/th/v_taurus/side.vmt')
resource.AddFile('materials/models/th/v_tfac/ac_grill.vtf')
resource.AddFile('materials/models/th/v_tfac/ac_grill.vmt')
resource.AddFile('materials/models/th/v_tfac/ac_grille.vtf')
resource.AddFile('materials/models/th/v_tfac/ac_grille.vmt')
resource.AddFile('materials/models/th/v_tfac/acChrome.vtf')
resource.AddFile('materials/models/th/v_tfac/acChrome.vmt')
resource.AddFile('materials/models/th/v_tfac/body_side.vtf')
resource.AddFile('materials/models/th/v_tfac/body_side.vmt')
resource.AddFile('materials/models/th/v_tfac/innerspring.vtf')
resource.AddFile('materials/models/th/v_tfac/innerspring.vmt')
resource.AddFile('materials/models/th/v_tfc_medic/medikitbody.vtf')
resource.AddFile('materials/models/th/v_tfc_medic/medikitbody.vmt')
resource.AddFile('materials/models/th/v_tfc_medic/medkit_bezel1.vtf')
resource.AddFile('materials/models/th/v_tfc_medic/medkit_bezel1.vmt')
resource.AddFile('materials/models/th/v_tfc_medic/medkit_bezel2.vtf')
resource.AddFile('materials/models/th/v_tfc_medic/medkit_bezel2.vmt')
resource.AddFile('materials/models/th/v_tfc_medic/readout1.vtf')
resource.AddFile('materials/models/th/v_tfc_medic/readout1.vmt')
resource.AddFile('materials/models/th/v_tfc_sniper/barrelchrome.vtf')
resource.AddFile('materials/models/th/v_tfc_sniper/barrelchrome.vmt')
resource.AddFile('materials/models/th/v_tfc_sniper/bodyside.vtf')
resource.AddFile('materials/models/th/v_tfc_sniper/bodyside.vmt')
resource.AddFile('materials/models/th/v_tfc_sniper/clip.vtf')
resource.AddFile('materials/models/th/v_tfc_sniper/clip.vmt')
resource.AddFile('materials/models/th/v_tfc_sniper/laserchrome.vtf')
resource.AddFile('materials/models/th/v_tfc_sniper/laserchrome.vmt')
resource.AddFile('materials/models/th/v_tfc_sniper/lenschrome1.vtf')
resource.AddFile('materials/models/th/v_tfc_sniper/lenschrome1.vmt')
resource.AddFile('materials/models/th/v_tfc_sniper/scope_bevel.vtf')
resource.AddFile('materials/models/th/v_tfc_sniper/scope_bevel.vmt')
resource.AddFile('materials/models/th/v_tfc_sniper/sight_rear.vtf')
resource.AddFile('materials/models/th/v_tfc_sniper/sight_rear.vmt')
resource.AddFile('materials/models/th/v_tfc_sniper/sight_wheel.vtf')
resource.AddFile('materials/models/th/v_tfc_sniper/sight_wheel.vmt')
resource.AddFile('materials/models/th/v_tfc_sniper/sightclip.vtf')
resource.AddFile('materials/models/th/v_tfc_sniper/sightclip.vmt')
resource.AddFile('materials/models/th/v_tfc_spanner/spanner_text.vtf')
resource.AddFile('materials/models/th/v_tfc_spanner/spanner_text.vmt')
resource.AddFile('materials/models/th/v_tfc_spanner/spannerCHROme.vtf')
resource.AddFile('materials/models/th/v_tfc_spanner/spannerCHROme.vmt')
resource.AddFile('materials/models/th/v_tnt/Chromefire.vtf')
resource.AddFile('materials/models/th/v_tnt/Chromefire.vmt')
resource.AddFile('materials/models/th/v_tnt/lighter.vtf')
resource.AddFile('materials/models/th/v_tnt/lighter.vmt')
resource.AddFile('materials/models/th/v_tnt/tntside.vtf')
resource.AddFile('materials/models/th/v_tnt/tntside.vmt')

--
-- World models
--

resource.AddFile('materials/models/th/world_models/wrld_9mmar/BX_Chrome1.vtf')
resource.AddFile('materials/models/th/world_models/wrld_9mmar/BX_Chrome1.vmt')
resource.AddFile('materials/models/th/world_models/wrld_9mmar/hkmsg90.vtf')
resource.AddFile('materials/models/th/world_models/wrld_9mmar/hkmsg90.vmt')
resource.AddFile('materials/models/th/world_models/wrld_9mmar/scope_chrome.vtf')
resource.AddFile('materials/models/th/world_models/wrld_9mmar/scope_chrome.vmt')
resource.AddFile('materials/models/th/world_models/wrld_9mmclip/gclip.vtf')
resource.AddFile('materials/models/th/world_models/wrld_9mmclip/gclip.vmt')
resource.AddFile('materials/models/th/world_models/wrld_9mmhandgun/glockback.vtf')
resource.AddFile('materials/models/th/world_models/wrld_9mmhandgun/glockback.vmt')
resource.AddFile('materials/models/th/world_models/wrld_9mmhandgun/glockfront.vtf')
resource.AddFile('materials/models/th/world_models/wrld_9mmhandgun/glockfront.vmt')
resource.AddFile('materials/models/th/world_models/wrld_9mmhandgun/glockside.vtf')
resource.AddFile('materials/models/th/world_models/wrld_9mmhandgun/glockside.vmt')
resource.AddFile('materials/models/th/world_models/wrld_9mmhandgun/glocktop1.vtf')
resource.AddFile('materials/models/th/world_models/wrld_9mmhandgun/glocktop1.vmt')
resource.AddFile('materials/models/th/world_models/wrld_antidote/boxart1.vtf')
resource.AddFile('materials/models/th/world_models/wrld_antidote/boxart1.vmt')
resource.AddFile('materials/models/th/world_models/wrld_antidote/boxart2.vtf')
resource.AddFile('materials/models/th/world_models/wrld_antidote/boxart2.vmt')
resource.AddFile('materials/models/th/world_models/wrld_antidote/bulletCHROME.vtf')
resource.AddFile('materials/models/th/world_models/wrld_antidote/bulletCHROME.vmt')
resource.AddFile('materials/models/th/world_models/wrld_antidote/cardboard.vtf')
resource.AddFile('materials/models/th/world_models/wrld_antidote/cardboard.vmt')
resource.AddFile('materials/models/th/world_models/wrld_ap9/tec9.vtf')
resource.AddFile('materials/models/th/world_models/wrld_ap9/tec9.vmt')
resource.AddFile('materials/models/th/world_models/wrld_ap9clip/tec9.vtf')
resource.AddFile('materials/models/th/world_models/wrld_ap9clip/tec9.vmt')
resource.AddFile('materials/models/th/world_models/wrld_chainsaw/blade.vtf')
resource.AddFile('materials/models/th/world_models/wrld_chainsaw/blade.vmt')
resource.AddFile('materials/models/th/world_models/wrld_chainsaw/guard.vtf')
resource.AddFile('materials/models/th/world_models/wrld_chainsaw/guard.vmt')
resource.AddFile('materials/models/th/world_models/wrld_chainsaw/handle.vtf')
resource.AddFile('materials/models/th/world_models/wrld_chainsaw/handle.vmt')
resource.AddFile('materials/models/th/world_models/wrld_chainsaw/motor.vtf')
resource.AddFile('materials/models/th/world_models/wrld_chainsaw/motor.vmt')
resource.AddFile('materials/models/th/world_models/wrld_chainsaw/string.vtf')
resource.AddFile('materials/models/th/world_models/wrld_chainsaw/string.vmt')
resource.AddFile('materials/models/th/world_models/wrld_crowbar/Chrome1.vtf')
resource.AddFile('materials/models/th/world_models/wrld_crowbar/Chrome1.vmt')
resource.AddFile('materials/models/th/world_models/wrld_crowbar/Chrome2(Brass).vtf')
resource.AddFile('materials/models/th/world_models/wrld_crowbar/Chrome2(Brass).vmt')
resource.AddFile('materials/models/th/world_models/wrld_crowbar/Umbrella_Base1.vtf')
resource.AddFile('materials/models/th/world_models/wrld_crowbar/Umbrella_Base1.vmt')
resource.AddFile('materials/models/th/world_models/wrld_gas/batcontact.vtf')
resource.AddFile('materials/models/th/world_models/wrld_gas/batcontact.vmt')
resource.AddFile('materials/models/th/world_models/wrld_gas/batpanel.vtf')
resource.AddFile('materials/models/th/world_models/wrld_gas/batpanel.vmt')
resource.AddFile('materials/models/th/world_models/wrld_gas/batside.vtf')
resource.AddFile('materials/models/th/world_models/wrld_gas/batside.vmt')
resource.AddFile('materials/models/th/world_models/wrld_gas/battop.vtf')
resource.AddFile('materials/models/th/world_models/wrld_gas/battop.vmt')
resource.AddFile('materials/models/th/world_models/wrld_gas/grey.vtf')
resource.AddFile('materials/models/th/world_models/wrld_gas/grey.vmt')
resource.AddFile('materials/models/th/world_models/wrld_hkg36/suitcase_front.vtf')
resource.AddFile('materials/models/th/world_models/wrld_hkg36/suitcase_front.vmt')
resource.AddFile('materials/models/th/world_models/wrld_isotopebox/suitcase_front.vtf')
resource.AddFile('materials/models/th/world_models/wrld_isotopebox/suitcase_front.vmt')
resource.AddFile('materials/models/th/world_models/wrld_isotopebox/suitcase_side.vtf')
resource.AddFile('materials/models/th/world_models/wrld_isotopebox/suitcase_side.vmt')
resource.AddFile('materials/models/th/world_models/wrld_isotopebox/suitcase_top.vtf')
resource.AddFile('materials/models/th/world_models/wrld_isotopebox/suitcase_top.vmt')
resource.AddFile('materials/models/th/world_models/wrld_medkit/MedFront.vtf')
resource.AddFile('materials/models/th/world_models/wrld_medkit/MedFront.vmt')
resource.AddFile('materials/models/th/world_models/wrld_medkit/MedHingeSide.vtf')
resource.AddFile('materials/models/th/world_models/wrld_medkit/MedHingeSide.vmt')
resource.AddFile('materials/models/th/world_models/wrld_medkit/MedLatchSide.vtf')
resource.AddFile('materials/models/th/world_models/wrld_medkit/MedLatchSide.vmt')
resource.AddFile('materials/models/th/world_models/wrld_medkit/MedTopBottom.vtf')
resource.AddFile('materials/models/th/world_models/wrld_medkit/MedTopBottom.vmt')
resource.AddFile('materials/models/th/world_models/wrld_shotgun/barrel_chrome.vtf')
resource.AddFile('materials/models/th/world_models/wrld_shotgun/barrel_chrome.vmt')
resource.AddFile('materials/models/th/world_models/wrld_shotgun/pump.vtf')
resource.AddFile('materials/models/th/world_models/wrld_shotgun/pump.vmt')
resource.AddFile('materials/models/th/world_models/wrld_shotgun/stock.vtf')
resource.AddFile('materials/models/th/world_models/wrld_shotgun/stock.vmt')
resource.AddFile('materials/models/th/world_models/wrld_shovel/-0silo2_pan2.vtf')
resource.AddFile('materials/models/th/world_models/wrld_shovel/-0silo2_pan2.vmt')
resource.AddFile('materials/models/th/world_models/wrld_shovel/wood.vtf')
resource.AddFile('materials/models/th/world_models/wrld_shovel/wood.vmt')
resource.AddFile('materials/models/th/world_models/wrld_silencer/chrome.vtf')
resource.AddFile('materials/models/th/world_models/wrld_silencer/chrome.vmt')
resource.AddFile('materials/models/th/world_models/wrld_silencer/glockback.vtf')
resource.AddFile('materials/models/th/world_models/wrld_silencer/glockback.vmt')
resource.AddFile('materials/models/th/world_models/wrld_silencer/glockfront.vtf')
resource.AddFile('materials/models/th/world_models/wrld_silencer/glockfront.vmt')
resource.AddFile('materials/models/th/world_models/wrld_silencer/glockside.vtf')
resource.AddFile('materials/models/th/world_models/wrld_silencer/glockside.vmt')
resource.AddFile('materials/models/th/world_models/wrld_silencer/glocktop1.vtf')
resource.AddFile('materials/models/th/world_models/wrld_silencer/glocktop1.vmt')
resource.AddFile('materials/models/th/world_models/wrld_taurus/body.vtf')
resource.AddFile('materials/models/th/world_models/wrld_taurus/body.vmt')
resource.AddFile('materials/models/th/world_models/wrld_taurus/side.vtf')
resource.AddFile('materials/models/th/world_models/wrld_taurus/side.vmt')
resource.AddFile('materials/models/th/world_models/wrld_taurusclip/gclip.vtf')
resource.AddFile('materials/models/th/world_models/wrld_taurusclip/gclip.vmt')
resource.AddFile('materials/models/th/world_models/wrld_tfac/suitcase_front.vtf')
resource.AddFile('materials/models/th/world_models/wrld_tfac/suitcase_front.vmt')
resource.AddFile('materials/models/th/world_models/wrld_tfac/suitcase_side.vtf')
resource.AddFile('materials/models/th/world_models/wrld_tfac/suitcase_side.vmt')
resource.AddFile('materials/models/th/world_models/wrld_tfac/suitcase_top.vtf')
resource.AddFile('materials/models/th/world_models/wrld_tfac/suitcase_top.vmt')
resource.AddFile('materials/models/th/world_models/wrld_tfc_medic/medkit_strap.vtf')
resource.AddFile('materials/models/th/world_models/wrld_tfc_medic/medkit_strap.vmt')
resource.AddFile('materials/models/th/world_models/wrld_tfc_medic/medkit_top.vtf')
resource.AddFile('materials/models/th/world_models/wrld_tfc_medic/medkit_top.vmt')
resource.AddFile('materials/models/th/world_models/wrld_tnt/fuse.vtf')
resource.AddFile('materials/models/th/world_models/wrld_tnt/fuse.vmt')
resource.AddFile('materials/models/th/world_models/wrld_tnt/tnt.vtf')
resource.AddFile('materials/models/th/world_models/wrld_tnt/tnt.vmt')
resource.AddFile('materials/models/th/world_models/wrld_tnt/tntb.vtf')
resource.AddFile('materials/models/th/world_models/wrld_tnt/tntb.vmt')
resource.AddFile('materials/models/th/world_models/wrld_tnt/tntside.vtf')
resource.AddFile('materials/models/th/world_models/wrld_tnt/tntside.vmt')
resource.AddFile('materials/models/th/world_models/wrld_tnt/tntt.vtf')
resource.AddFile('materials/models/th/world_models/wrld_tnt/tntt.vmt')

--
-- Sprites
--

resource.AddFile('materials/sprites/th/fthrow/fthrow000.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow000.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow001.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow001.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow002.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow002.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow003.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow003.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow004.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow004.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow005.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow005.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow006.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow006.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow007.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow007.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow008.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow008.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow009.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow009.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow010.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow010.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow011.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow011.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow012.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow012.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow013.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow013.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow014.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow014.vmt')
resource.AddFile('materials/sprites/th/fthrow/fthrow015.vtf')
resource.AddFile('materials/sprites/th/fthrow/fthrow015.vmt')

--
-- VGUI
--

resource.AddFile('materials/vgui/th/nmxhair2.vtf')
resource.AddFile('materials/vgui/th/nmxhair2.vmt')


--------------------------------------------------------------------

-- Models

--------------------------------------------------------------------

resource.AddFile('models/th/backpack/backpack.mdl')
resource.AddFile('models/th/crossbow_bolt/crossbow_bolt.mdl')

resource.AddFile('models/th/p_9mmar/p_9mmar.mdl')
resource.AddFile('models/th/p_9mmhandgun/p_9mmhandgun.mdl')
resource.AddFile('models/th/p_357/p_357.mdl')
resource.AddFile('models/th/p_ap9/p_ap9.mdl')
resource.AddFile('models/th/p_chainsaw/p_chainsaw.mdl')
resource.AddFile('models/th/p_crossbow/p_crossbow.mdl')
resource.AddFile('models/th/p_crowbar/p_crowbar.mdl')
resource.AddFile('models/th/p_egon/p_egon.mdl')
resource.AddFile('models/th/p_hkg36/p_hkg36.mdl')
resource.AddFile('models/th/p_medkit/p_medkit.mdl')
resource.AddFile('models/th/p_mini2/p_mini2.mdl')
resource.AddFile('models/th/p_satchel/p_satchel.mdl')
resource.AddFile('models/th/p_shotgun/p_shotgun.mdl')
resource.AddFile('models/th/p_shovel/p_shovel.mdl')
resource.AddFile('models/th/p_sniper2/p_sniper2.mdl')
resource.AddFile('models/th/p_spanner/p_spanner.mdl')
resource.AddFile('models/th/p_taurus/p_taurus.mdl')
resource.AddFile('models/th/p_tnt/p_tnt.mdl')
resource.AddFile('models/th/p_tripmine/p_tripmine.mdl')

resource.AddFile('models/th/v_9mmar/v_9mmar.mdl')
resource.AddFile('models/th/v_9mmhandgun/v_9mmhandgun.mdl')
resource.AddFile('models/th/v_357/v_357.mdl')
resource.AddFile('models/th/v_ap9/v_ap9.mdl')
resource.AddFile('models/th/v_chainsaw/v_chainsaw.mdl')
resource.AddFile('models/th/v_crossbow/v_crossbow.mdl')
resource.AddFile('models/th/v_crowbar/v_crowbar.mdl')
resource.AddFile('models/th/v_egon/v_egon.mdl')
resource.AddFile('models/th/v_hkg36/v_hkg36.mdl')
resource.AddFile('models/th/v_satchel/v_satchel.mdl')
resource.AddFile('models/th/v_satchel_radio/v_satchel_radio.mdl')
resource.AddFile('models/th/v_shotgun/v_shotgun.mdl')
resource.AddFile('models/th/v_shovel/v_shovel.mdl')
resource.AddFile('models/th/v_taurus/v_taurus.mdl')
resource.AddFile('models/th/v_tfac/v_tfac.mdl')
resource.AddFile('models/th/v_tfc_medic/v_tfc_medic.mdl')
resource.AddFile('models/th/v_tfc_sniper/v_tfc_sniper.mdl')
resource.AddFile('models/th/v_tfc_spanner/v_tfc_spanner.mdl')
resource.AddFile('models/th/v_tnt/v_tnt.mdl')
resource.AddFile('models/th/v_tripmine/v_tripmine.mdl')

resource.AddFile('models/th/w_9mmar/w_9mmar.mdl')
resource.AddFile('models/th/w_9mmclip/w_9mmclip.mdl')
resource.AddFile('models/th/w_9mmhandgun/w_9mmhandgun.mdl')
resource.AddFile('models/th/w_antidote/w_antidote.mdl')
resource.AddFile('models/th/w_ap9/w_ap9.mdl')
resource.AddFile('models/th/w_ap9clip/w_ap9clip.mdl')
resource.AddFile('models/th/w_chainsaw/w_chainsaw.mdl')
resource.AddFile('models/th/w_crowbar/w_crowbar.mdl')
resource.AddFile('models/th/w_egon/w_egon.mdl')
resource.AddFile('models/th/w_gas/w_gas.mdl')
resource.AddFile('models/th/w_grenade/w_grenade.mdl')
resource.AddFile('models/th/w_hkg36/w_hkg36.mdl')
resource.AddFile('models/th/w_isotopebox/w_isotopebox.mdl')
resource.AddFile('models/th/w_medkit/w_medkit.mdl')
resource.AddFile('models/th/w_shotgun/w_shotgun.mdl')
resource.AddFile('models/th/w_shovel/w_shovel.mdl')
resource.AddFile('models/th/w_silencer/w_silencer.mdl')
resource.AddFile('models/th/w_taurus/w_taurus.mdl')
resource.AddFile('models/th/w_taurusclip/w_taurusclip.mdl')
resource.AddFile('models/th/w_tfac/w_tfac.mdl')
resource.AddFile('models/th/w_tfc_medkit/w_tfc_medkit.mdl')
resource.AddFile('models/th/w_tnt/w_tnt.mdl')

--------------------------------------------------------------------

-- Sounds

--------------------------------------------------------------------

resource.AddFile('sound/th/weapons/ap9_bolt.wav')
resource.AddFile('sound/th/weapons/ap9_clipin.wav')
resource.AddFile('sound/th/weapons/ap9_clipout.wav')
resource.AddFile('sound/th/weapons/ap9_fire.wav')
resource.AddFile('sound/th/weapons/asscan1.wav')
resource.AddFile('sound/th/weapons/asscan2.wav')
resource.AddFile('sound/th/weapons/asscan3.wav')
resource.AddFile('sound/th/weapons/asscan4.wav')
resource.AddFile('sound/th/weapons/flmfire2.wav')
resource.AddFile('sound/th/weapons/hks1.wav')
resource.AddFile('sound/th/weapons/hks2.wav')
resource.AddFile('sound/th/weapons/hks3.wav')
resource.AddFile('sound/th/weapons/sniper.wav')
resource.AddFile('sound/th/weapons/tau_back.wav')
resource.AddFile('sound/th/weapons/tau_clipin.wav')
resource.AddFile('sound/th/weapons/tau_clipout.wav')
resource.AddFile('sound/th/weapons/tau_fire.wav')
resource.AddFile('sound/th/weapons/tau_release.wav')


--------------------------------------------------------------------

-- Scripts

--------------------------------------------------------------------

resource.AddFile( 'scripts/vehicles/game_sounds_weapons_th.txt' )
