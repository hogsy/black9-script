class HoverBike extends SHover;

#exec OBJ LOAD FILE=..\animations\GeistHoverAsset.ukx

defaultproperties
{
	FrontThrustOffset=(X=110,Y=0,Z=10)
	RearThrustOffset=(X=-110,Y=0,Z=10)
	HoverSoftness=0.05
	HoverPenScale=1.5
	HoverCheckDist=130
	UprightStiffness=500
	UprightDamping=300
	MaxThrust=45
	MaxSteerTorque=120
	ForwardDampFactor=0.01
	LateralDampFactor=0.5
	SteerDampFactor=60
	PitchTorqueFactor=35
	BankTorqueFactor=50
	BankDampFactor=40
	StopThreshold=100
	ExitPositions=/* Array type was not detected. */
	EntryPositions=/* Array type was not detected. */
	DrivePos=(X=0,Y=0,Z=130)
	bDrawMeshInFP=true
	bDrawDriverInTP=true
	FPCamPos=(X=0,Y=0,Z=200)
	TPCamLookat=(X=0,Y=0,Z=120)
	VehicleMass=4
	Mesh=SkeletalMesh'GeistHoverAsset.GeistHover2'
	begin object name=KParams0 class=KarmaParamsRBFull
	// Object Offset:0x00072594
	KInertiaTensor[0]=1.3
	KInertiaTensor[3]=4
	KInertiaTensor[5]=4.5
	KLinearDamping=0
	KAngularDamping=0
	KStartEnabled=true
	bHighDetailOnly=false
	bClientOnly=false
	bKDoubleTickRate=true
	bKStayUpright=true
	bKAllowRotate=true
	SafeTimeMode=2
	KFriction=0.5
object end
// Reference: KarmaParamsRBFull'HoverBike.KParams0'
KParams=KParams0
}