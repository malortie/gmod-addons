$modelname th/v_satchel/v_satchel.mdl
$cdmaterials models/th/v_satchel models/th/v_hands models/v_satchel

$pushd references

$bodygroup studio {
	studio satchel_hand_fix
}

$bodygroup studio {
	studio satchel_charge
}

$popd

$include rules/commonbones.qci

$pushd anims
$include anims/animations.qci
$popd