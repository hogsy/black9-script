class DropShip extends Vehicle;

#exec OBJ LOAD FILE=..\staticmeshes\VehicleStaticMeshes.usx Package=VehicleStaticMeshes

#exec AUDIO IMPORT FILE="Sounds\dropship\JetEngineWindup.WAV" NAME="DSstartup" GROUP="Dropship"
#exec AUDIO IMPORT FILE="Sounds\dropship\AfterBurner.WAV" NAME="DSafterburner" GROUP="Dropship"
#exec AUDIO IMPORT FILE="Sounds\dropship\JetEngine.WAV" NAME="DSjetengine" GROUP="Dropship"
#exec AUDIO IMPORT FILE="Sounds\dropship\Hydraulic1.WAV" NAME="DShydraulic" GROUP="Dropship"
#exec AUDIO IMPORT FILE="Sounds\dropship\Hydr_Clunk.WAV" NAME="DSClunk" GROUP="Dropship"

var rotator EngineRot;	// for engine pitching

var bool bEnginesOn;
var bool bTriggered;
var bool bAfterBurner;
var bool bLowerGear;
var int flyingpitch;
var rotator StartView;
var Controller PendingController;
var DropShipLoadTrigger LoadTrigger;

var DSEngineFront FrontEngines, RearEngines;
var DropShipVehiclePart Canopy, RearLandingGear, BayDoor, LeftLandingGear, RightLandingGear;

defaultproperties
{
	bCrawler=true
	bCanStrafe=true
	AirSpeed=2500
	AccelRate=2500
	LandMovementState=PlayerHelicoptering
	WaterMovementState=PlayerHelicoptering
	Physics=5
	DrawType=8
	StaticMesh=StaticMesh'VehicleStaticMeshes.DropShip.DropShipBody'
	DrawScale=2.5
	SoundRadius=30000
	TransientSoundRadius=30000
	CollisionRadius=320
	CollisionHeight=295
	RotationRate=(Pitch=20000,Yaw=25000,Roll=12288)
}