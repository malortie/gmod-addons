$modelname th/v_tnt/v_tnt.mdl
$cdmaterials models/th/v_tnt models/th/world_models/wrld_tnt models/th/v_hands models/v_crowbar

$pushd references

$bodygroup studio {
	studio tnt
}

$bodygroup studio {
	studio tnt_lighter
}

$popd

$include rules/commonbones.qci
$include rules/attachments.qci

$pushd anims
$include anims/animations.qci
$popd