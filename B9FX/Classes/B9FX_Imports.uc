//=============================================================================
// B9FX_Imports.uc
//
// Consolidated resource imports for this package
//
// 
//=============================================================================

class B9FX_Imports extends Object; // Do-nothing class so the compiler won't complain


// Sounds
//
#exec OBJ LOAD FILE=..\Sounds\B9Weapons_sounds.uax PACKAGE=B9Weapons_sounds
#exec OBJ LOAD FILE=..\Sounds\BulletSounds.uax PACKAGE=BulletSounds


// Meshes
//
#exec OBJ LOAD FILE=..\Animations\B9Effects_models.ukx  PACKAGE=B9Effects_models

// Muzzle flashes
//
#exec OBJ LOAD FILE=..\StaticMeshes\MuzzleFlashes3D_m.usx PACKAGE=MuzzleFlashes3D_m


// Bullet impacts
//
#exec MESH IMPORT MESH=BulletImpact ANIVFILE=..\botpack\MODELS\bulletimpact_a.3d DATAFILE=..\botpack\MODELS\bulletimpact_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BulletImpact X=0 Y=0 Z=0 PITCH=-64
#exec MESH SEQUENCE MESH=BulletImpact SEQ=All          STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BulletImpact SEQ=hit          STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=BulletImpact MESH=BulletImpact
#exec MESHMAP SCALE MESHMAP=BulletImpact X=0.12 Y=0.12 Z=0.3
#exec OBJ LOAD FILE=..\botpack\Textures\HitFx.utx  PACKAGE=WarEffects.HitFx
#exec MESHMAP SETTEXTURE MESHMAP=BulletImpact NUM=1 TEXTURE=WarEffects.HitFx.Impact_A00

/*
// "Chips" (bullet impacts)
//
#exec MESH IMPORT MESH=B9_ChipM ANIVFILE=..\botpack\MODELS\B9_Chip_a.3D DATAFILE=..\botpack\MODELS\B9_Chip_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=B9_ChipM X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=B9_ChipM SEQ=All       STARTFRAME=0   NUMFRAMES=4
#exec MESH SEQUENCE MESH=B9_ChipM SEQ=Position1 STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=B9_ChipM SEQ=Position2 STARTFRAME=1   NUMFRAMES=1
#exec MESH SEQUENCE MESH=B9_ChipM SEQ=Position3 STARTFRAME=2   NUMFRAMES=1
#exec MESH SEQUENCE MESH=B9_ChipM SEQ=Position4 STARTFRAME=3   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=B9_Chip1 FILE=..\botpack\MODELS\B9_Chip.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=B9_ChipM X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=B9_ChipM NUM=1 TEXTURE=B9_Chip1
*/

// Sparks
//
#exec MESH IMPORT MESH=B9_SmallSparkM ANIVFILE=..\botpack\MODELS\Spark_a.3D DATAFILE=..\botpack\MODELS\Spark_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=B9_SmallSparkM X=0 Y=0 Z=0 PITCH=-64
#exec MESH SEQUENCE MESH=B9_SmallSparkM SEQ=All       STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=B9_SmallSparkM SEQ=Explosion STARTFRAME=0   NUMFRAMES=2
#exec TEXTURE IMPORT NAME=JSmlSpark1 FILE=..\botpack\MODELS\Spark.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=B9_SmallSparkM X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=B9_SmallSparkM NUM=1 TEXTURE=JSmlSpark1

#exec TEXTURE IMPORT NAME=Sparky FILE=..\botpack\MODELS\spark.pcx GROUP=Effects

/*
// Smoke Puff
//
#exec OBJ LOAD FILE=textures\utSmoke.utx PACKAGE=WarEffects.utsmoke
*/

// Wall Hit
//
#exec AUDIO IMPORT FILE="..\botpack\Sounds\sniperrifle\Ricochet.WAV" NAME="Ricochet" GROUP="sniperrifle"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\sniperrifle\imp01.WAV" NAME="Impact1" GROUP="sniperrifle"
#exec AUDIO IMPORT FILE="..\botpack\Sounds\sniperrifle\imp02.WAV" NAME="Impact2" GROUP="sniperrifle"


// Fire! Fire!
//
#exec OBJ LOAD FILE=..\textures\FireTest.utx PACKAGE=FireTest


// Misc
//
#exec OBJ LOAD FILE=..\textures\WarEffectsTextures.utx PACKAGE=WarEffectsTextures
#exec OBJ LOAD FILE=..\StaticMeshes\SC_MeshParticles.usx PACKAGE=SC_MeshParticles

