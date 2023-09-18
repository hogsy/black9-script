//=============================================================================
// ThighPads.
//=============================================================================
class ThighPads extends WarfareArmorPickup;

#exec MESH IMPORT MESH=ThighPads ANIVFILE=..\botpack\MODELS\ThighPads_a.3d DATAFILE=..\botpack\MODELS\ThighPads_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ThighPads X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=ThighPads SEQ=All                      STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ThighPads SEQ=sit                      STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=ThighPads MESH=ThighPads
#exec MESHMAP SCALE MESHMAP=ThighPads X=0.04 Y=0.04 Z=0.08
#exec TEXTURE IMPORT NAME=JThighPads_01 FILE=..\botpack\MODELS\ThighPads1.PCX GROUP=Skins LODSET=2
#exec MESHMAP SETTEXTURE MESHMAP=ThighPads NUM=1 TEXTURE=JThighPads_01
#exec MESHMAP SETTEXTURE MESHMAP=ThighPads NUM=2 TEXTURE=JThighPads_01

defaultproperties
{
	MaxDesireability=1.8
	InventoryType=Class'ThighPadInv'
	RespawnTime=30
	PickupMessage="You got the Thigh Pads."
	PickupSound=Sound'Pickups.ArmorUT'
	Mesh=VertMesh'ThighPads'
	AmbientGlow=64
	CollisionRadius=30
	CollisionHeight=30
}