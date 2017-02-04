$modelname th/w_grenade/w_grenade.mdl
$cdmaterials models/world_models/wrld_grenade

$body studio references/w_grenade_reference

$include rules/hitbox.qci

$pushd anims
$include anims/animations.qci
$popd

$pushd physics
$include physics/physbox.qci
$popd