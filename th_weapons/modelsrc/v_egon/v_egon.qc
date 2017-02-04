$modelname th/v_egon/v_egon.mdl
$cdmaterials models/th/v_egon models/th/v_hands models/v_egon

$pushd references

$bodygroup studio {
	studio flame
}

$bodygroup studio {
	studio egon_hands
}

$popd

$include rules/commonbones.qci
$include rules/attachments.qci

$pushd anims
$include anims/animations.qci
$popd