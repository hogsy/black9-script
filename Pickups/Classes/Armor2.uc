//=============================================================================
// Armor2 powerup.
//=============================================================================
class Armor2 extends WarfareArmorPickup;

#exec MESH IMPORT MESH=Armor2M ANIVFILE=..\botpack\MODELS\armor2_a.3D DATAFILE=..\botpack\MODELS\armor2_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Armor2M X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=Armor2M SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jarmor2 FILE=..\botpack\MODELS\armor3.PCX GROUP="Skins" LODSET=2
#exec MESHMAP SCALE MESHMAP=Armor2M X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=Armor2M NUM=1 TEXTURE=Jarmor2 
#exec AUDIO IMPORT FILE="..\botpack\Sounds\Pickups\ARMOURUT.WAV" NAME="ArmorUT" GROUP="Pickups"

defaultproperties
{
	MaxDesireability=2
	InventoryType=Class'ArmorVest'
	RespawnTime=30
	PickupMessage="You got the Body Armor."
	PickupSound=Sound'Pickups.ArmorUT'
	Mesh=VertMesh'Armor2M'
	AmbientGlow=64
	CollisionHeight=11
}