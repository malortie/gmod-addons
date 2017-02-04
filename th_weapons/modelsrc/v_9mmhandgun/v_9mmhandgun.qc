$modelname th/v_9mmhandgun/v_9mmhandgun.mdl
$cdmaterials models/th/v_9mmhandgun models/th/v_hands models/v_glock

$pushd references

$bodygroup studio {
	studio glock_reference2
}

$bodygroup studio {
	studio clip_reference
}

$bodygroup silencer {
	blank
	studio glock_reference(silencer)
}

$popd

$include rules/commonbones.qci
$include rules/attachments.qci

$pushd anims
$include anims/animations.qci
$popd