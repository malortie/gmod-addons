$modelname th/v_chainsaw/v_chainsaw.mdl
$cdmaterials models/th/v_chainsaw models/th/v_hands models/v_crossbow

$pushd references

$bodygroup studio
{
	studio testaroo2
}
$bodygroup studio
{
	studio chainsaw_hands
}

$popd

$include rules/attachments.qci

$pushd anims
$include anims/animations.qci
$popd