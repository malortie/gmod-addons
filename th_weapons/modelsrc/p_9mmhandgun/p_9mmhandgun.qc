$modelname th/p_9mmhandgun/p_9mmhandgun.mdl
$cdmaterials models/th/world_models/wrld_silencer

$bodygroup studio
{
	studio references/wrld_silencer
}

$bodygroup silencer 
{
	blank 
	studio references/reference_silencer
}

$include rules/hitbox.qci
$include rules/attachments.qci

$pushd anims
$include anims/animations.qci
$popd