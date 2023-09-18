Class DSLandingGear extends DropShipVehiclePart;

#exec MESH  MODELIMPORT MESH=DSLandingGearMesh MODELFILE=models\Frontleg.PSK LODSTYLE=10
#exec MESH  ORIGIN MESH=DSLandingGearMesh X=0 Y=0 Z=0 YAW=128 PITCH=0 ROLL=0
#exec ANIM  IMPORT ANIM=DSLandingGearAnims ANIMFILE=models\Frontleg.PSA COMPRESS=1
#exec MESHMAP SCALE MESHMAP=DSLandingGearMesh X=2.5 Y=2.5 Z=2.5

#exec MESH  DEFAULTANIM MESH=DSLandingGearMesh ANIM=DSLandingGearAnims
#exec ANIM DIGEST  ANIM=DSLandingGearAnims USERAWINFO VERBOSE 

#EXEC MESHMAP SETTEXTURE MESHMAP=DSLandingGearMesh NUM=0 TEXTURE=DropShipTex

function BeginPlay()
{
	Super.BeginPlay();
	TweenAnim('FrontLegUp', 0.01); // FIXME - this should be the default first frame
}

function InFlightModel()
{
	bHidden = true;
	TweenAnim('FrontLegDown', 0.01);
}

defaultproperties
{
	DrawType=2
	Mesh=SkeletalMesh'DSLandingGearMesh'
	CollisionRadius=30
	CollisionHeight=35
}