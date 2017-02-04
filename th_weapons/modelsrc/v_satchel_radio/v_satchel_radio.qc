$modelname th/v_satchel_radio/v_satchel_radio.mdl
$cdmaterials models/th/v_satchel_radio models/th/v_hands models/v_satchel

$pushd references

$bodygroup studio {
	studio satchel_radio_hand
}

$bodygroup studio {
	studio satchel_radio_detonator
}

$popd

$include rules/commonbones.qci

$pushd anims
$include anims/animations.qci
$popd