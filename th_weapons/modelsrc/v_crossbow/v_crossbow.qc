$modelname th/v_crossbow/v_crossbow.mdl
$cdmaterials models/th/v_crossbow models/th/v_hands models/v_crossbow

$pushd references

$bodygroup studio
{
	studio compound_scope
}
$bodygroup studio
{
	studio crossbow_hand
}

$popd

$include rules/commonbones.qci

$pushd anims
$include anims/animations.qci
$popd