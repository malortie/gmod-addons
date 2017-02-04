$modelname th/v_357/v_357.mdl
$cdmaterials models/th/v_357 models/th/v_hands models/v_python

$pushd references

$bodygroup studio {
	studio python_gun2
}

$bodygroup studio {
	studio python_bullets
}

$bodygroup studio {
	studio python_speedload
}

$bodygroup studio {
	studio python_hands
}

$bodygroup scope {
	blank
	studio python_lasersight
}

$popd

$include rules/commonbones.qci
$include rules/attachments.qci

$pushd anims
$include anims/animations.qci
$popd