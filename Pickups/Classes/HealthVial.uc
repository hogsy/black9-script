//=============================================================================
// Vial.
//=============================================================================
class HealthVial extends TournamentHealth;

#exec MESH IMPORT MESH=Vial ANIVFILE=..\botpack\MODELS\Vial_a.3d DATAFILE=..\botpack\MODELS\Vial_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=Vial STRENGTH=0.6
#exec MESH ORIGIN MESH=Vial X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=Vial SEQ=All  STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Vial SEQ=VIAL STARTFRAME=0 NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JVial0 FILE=..\botpack\MODELS\vial.PCX GROUP=Skins LODSET=2
#exec MESHMAP NEW   MESHMAP=Vial MESH=Vial
#exec MESHMAP SCALE MESHMAP=Vial X=0.02 Y=0.02 Z=0.04

#exec OBJ LOAD FILE=..\botpack\Textures\ShaneFx.utx  PACKAGE=Pickups.ShaneFx
#exec MESHMAP SETTEXTURE MESHMAP=Vial NUM=0 TEXTURE=JVial0
#exec MESHMAP SETTEXTURE MESHMAP=Vial NUM=1 TEXTURE=Pickups.ShaneFx.bluestuff
#exec MESHMAP SETTEXTURE MESHMAP=Vial NUM=2 TEXTURE=Pickups.ShaneFx.Top

defaultproperties
{
	HealingAmount=5
	bSuperHeal=true
	RespawnTime=30
	PickupMessage="You picked up a Health Vial +"
	PickupSound=Sound'Pickups.UTHealth'
	Mesh=VertMesh'Vial'
	CollisionRadius=14
	CollisionHeight=16
}