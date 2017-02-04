$modelname th/v_shotgun/v_shotgun.mdl
$cdmaterials models/th/v_shotgun models/th/v_hands models/v_shotgun

$pushd references

$bodygroup studio {
	studio v_shotgun_reference2
}

$bodygroup shell {
	studio shell
}

$popd

$include rules/commonbones.qci
$include rules/attachments.qci

$pushd anims
$include anims/animations.qci
$popd