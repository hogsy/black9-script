//===============================================================================
//  [COG Pistol ]  
//===============================================================================

class WeapCOGPistol extends WarfareWeapon;

#exec MESH  MODELIMPORT MESH=geistpistolMesh MODELFILE=..\WarClassContent\Models\geistpistol.PSK LODSTYLE=0
#exec MESH  ORIGIN MESH=geistpistolMesh X=0 Y=0 Z=64 YAW=128 PITCH=00 ROLL=00
#exec ANIM  IMPORT ANIM=geistpistolAnims ANIMFILE=..\WarClassContent\Models\geistpistol.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP SCALE MESHMAP=geistpistolMesh X=.02 Y=.02 Z=.02
#exec MESH  DEFAULTANIM MESH=geistpistolMesh ANIM=geistpistolAnims

#exec ANIM SEQUENCE ANIM=geistpistolAnims SEQ=load GROUP=Select

#exec ANIM DIGEST ANIM=geistpistolAnims USERAWINFO VERBOSE

#exec OBJ LOAD FILE=..\textures\warfareguns.utx PACKAGE=WarfareGuns
#EXEC TEXTURE IMPORT NAME=WeaponUnseen FILE=..\WarClassContent\Models\green.bmp GROUP=Skins

/*

 * Animation sequence load    0  Tracktime: 23.000000 rate: 30.000000 
	  First raw frame  0  total raw frames 23  group: [None]

 * Animation sequence shoot    1  Tracktime: 6.000000 rate: 30.000000 
	  First raw frame  23  total raw frames 6  group: [None]

 * Animation sequence holster    2  Tracktime: 16.000000 rate: 30.000000 
	  First raw frame  29  total raw frames 16  group: [None]

 * Animation sequence reload    3  Tracktime: 80.000000 rate: 30.000000 
	  First raw frame  45  total raw frames 80  group: [None]

*/

// 3rd person/ pickup mesh
#exec MESH  MODELIMPORT MESH=GeistPistol3 MODELFILE=..\WarClassContent\Models\GeistPistol3.PSK LODSTYLE=0
#exec MESH  ORIGIN MESH=GeistPistol3 X=0 Y=0 Z=64 YAW=128 PITCH=00 ROLL=00
#exec ANIM  IMPORT ANIM=GeistPistol3Anims ANIMFILE=..\WarClassContent\Models\GeistPistol3.PSA COMPRESS=1 MAXKEYS=999999 IMPORTSEQS=1
#exec MESHMAP SCALE MESHMAP=GeistPistol3 X=.15 Y=.15 Z=.15
#exec MESH  DEFAULTANIM MESH=GeistPistol3 ANIM=GeistPistol3Anims

#exec ANIM DIGEST ANIM=GeistPistol3Anims USERAWINFO VERBOSE

simulated function PlayFiring()
{
	IncrementFlashCount();
	PlayOwnedSound(FireSound, SLOT_None, 3.0);
	PlayAnim('Shoot1',0.5 + 0.5 * FireAdjust, 0.05);
}

defaultproperties
{
	AmmoName=Class'PistolAmmo'
	FireOffset=(X=20,Y=4,Z=-5)
	ShakeMag=350
	shaketime=0.2
	ShakeVert=(X=0,Y=0,Z=4)
	AIRating=0.41
	FireSound=Sound'sniperrifle.SniperFire'
	SelectSound=Sound'Rifle.RiflePickup'
	DisplayFOV=30
	PickupClass=Class'PickupCOGPistol'
	PlayerViewOffset=(X=30,Y=6,Z=-6)
	BobDamping=0.975
	ItemName="COG Pistol"
	Mesh=SkeletalMesh'geistpistolMesh'
	DrawScale=0.4
	Skins=/* Array type was not detected. */
}