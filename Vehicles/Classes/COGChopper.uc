class COGChopper extends SCopter;

defaultproperties
{
	UprightStiffness=500
	UprightDamping=300
	MaxThrustForce=100
	LongDamping=0.05
	MaxStrafeForce=80
	LatDamping=0.8
	MaxRiseForce=60
	UpDamping=0.2
	TurnTorqueFactor=600
	TurnTorqueMax=200
	TurnDamping=50
	MaxYawRate=1.5
	PitchTorqueFactor=200
	PitchTorqueMax=35
	PitchDamping=20
	RollTorqueTurnFactor=450
	RollTorqueStrafeFactor=50
	RollTorqueMax=50
	RollDamping=30
	StopThreshold=100
	ExitPositions=/* Array type was not detected. */
	EntryPositions=/* Array type was not detected. */
	TPCamDistance=1000
	VehicleMass=4
	Mesh=SkeletalMesh'COGChopperAsset.COG_Copter2'
	begin object name=KParams0 class=KarmaParamsRBFull
	// Object Offset:0x000728DC
	KInertiaTensor[0]=1
	KInertiaTensor[3]=3
	KInertiaTensor[5]=3.5
	KCOMOffset=(X=-0.25,Y=0,Z=0)
	KLinearDamping=0
	KAngularDamping=0
	KStartEnabled=true
	bKNonSphericalInertia=true
	KActorGravScale=0
	bHighDetailOnly=false
	bClientOnly=false
	bKDoubleTickRate=true
	bKStayUpright=true
	bKAllowRotate=true
	SafeTimeMode=2
	KFriction=0.5
object end
// Reference: KarmaParamsRBFull'COGChopper.KParams0'
KParams=KParams0
}