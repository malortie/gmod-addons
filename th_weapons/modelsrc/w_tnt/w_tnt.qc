$modelname th/w_tnt/w_tnt.mdl
$cdmaterials models/th/world_models/wrld_tnt

$body studio references/tnt

$include rules/hitbox.qci

$pushd anims
$include anims/animations.qci
$popd

$pushd physics
$include physics/physbox.qci
$popd