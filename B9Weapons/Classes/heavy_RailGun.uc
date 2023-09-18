//=============================================================================
// heavy_RailGun.uc
//
// Rail Gun heavy weapon
//
// 
//=============================================================================


class heavy_RailGun extends B9HeavyWeapon;


//////////////////////////////////
// Variables
//
var vector TracerOffset;
var private float	fPenetrationThroughWall;
var private float	fPenetrationThroughPawn;
var private float	fTraceDistAfterWall;
var private float	fTraceDistAfterPawn;


//////////////////////////////////
// Initialization
//

defaultproperties
{
	fPenetrationThroughWall=40
	fPenetrationThroughPawn=60
	fTraceDistAfterWall=10000
	fTraceDistAfterPawn=750
	fAmmoExpendedPerShot=1
	fUniqueID=20
	fForceFeedbackEffectName="RailFire"
	fIniLookupName="RailGun"
	AmmoName=Class'ammo_RailGun'
	PickupAmmoCount=5
	ReloadCount=1
	bRapidFire=true
	TraceDist=15600
	MaxRange=15600
	PickupClass=Class'heavy_RailGun_Pickup'
	AttachmentClass=Class'heavy_RailGun_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.gen_armature_gun_bricon'
	ItemName="RailGun"
	Mesh=SkeletalMesh'B9Weapons_models.RailGun_mesh'
}