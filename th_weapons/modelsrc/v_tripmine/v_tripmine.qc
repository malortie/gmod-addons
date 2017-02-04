$modelname th/v_tripmine/v_tripmine.mdl
$cdmaterials models/th/v_tripmine models/th/v_hands models/v_tripmine

$pushd references

$bodygroup hands {
	studio tripmine_hands
	blank
}

$bodygroup mine {
	studio tripmine_mine
	studio tripmine_boned_world
}

$popd

$include rules/commonbones.qci

$pushd anims
$include anims/animations.qci
$popd