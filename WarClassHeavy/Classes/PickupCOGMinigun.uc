class PickupCOGMinigun extends WarfareWeaponPickup;

#exec TEXTURE IMPORT NAME=Mini_t FILE=..\WarClassContent\MODELS\Mini.PCX GROUP="Skins" LODSET=2

#exec MESH IMPORT MESH=MiniHand ANIVFILE=..\WarClassContent\MODELS\minihand_a.3D DATAFILE=..\WarClassContent\MODELS\minihand_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MiniHand X=5 Y=270 Z=-20 YAW=64 PITCH=0
#exec MESH SEQUENCE MESH=MiniHand SEQ=All STARTFRAME=0  NUMFRAMES=11
#exec MESH SEQUENCE MESH=MiniHand SEQ=Shoot1  STARTFRAME=1  NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=MiniHand X=0.12 Y=0.12 Z=0.24
#exec MESHMAP SETTEXTURE MESHMAP=MiniHand NUM=1 TEXTURE=Mini_t

defaultproperties
{
	InventoryType=Class'WeapCOGMinigun'
	PickupMessage="You picked up a COG Minigun."
	PickupSound=Sound'WarEffects.Pickups.WeaponPickup'
	DrawType=8
	StaticMesh=StaticMesh'GunMeshes.warcoggunner.chaingun'
	DrawScale=9
	Skins=/* Array type was not detected. */
	CollisionRadius=34
	CollisionHeight=8
}