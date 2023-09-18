class Armadillo extends SCar;

#exec OBJ LOAD FILE=..\animations\COGArmadilloAsset.ukx
#exec OBJ LOAD FILE=..\sounds\BuggySounds.uax

defaultproperties
{
	WheelSoftness=0.01
	WheelPenScale=1
	WheelRestitution=0.1
	WheelInertia=0.1
	WheelLongFrictionFunc=(Points=/* Array type was not detected. */,InVal=0,OutVal=0)
	WheelLongSlip=0.001
	WheelLatSlipFunc=(Points=/* Array type was not detected. */,InVal=0,OutVal=0)
	WheelLongFrictionScale=0.7
	WheelLatFrictionScale=1.2
	WheelHandbrakeSlip=2
	WheelHandbrakeFriction=0.7
	WheelSuspensionTravel=25
	WheelSuspensionOffset=12
	FTScale=0.03
	ChassisTorqueScale=1
	MinBrakeFriction=1.5
	MaxSteerAngle=25
	TorqueCurve=(Points=/* Array type was not detected. */,InVal=0,OutVal=5)
	GearRatios[0]=-0.5
	GearRatios[1]=0.4
	GearRatios[2]=0.65
	GearRatios[3]=0.85
	GearRatios[4]=1.1
	TransRatio=0.2
	ChangeUpPoint=2000
	ChangeDownPoint=1000
	LSDFactor=1
	EngineBrakeFactor=0.0001
	EngineBrakeRPMScale=0.1
	MaxBrakeTorque=20
	SteerSpeed=110
	StopThreshold=100
	HandbrakeThresh=200
	EngineInertia=0.1
	IdleRPM=500
	IdleSound=Sound'BuggySounds.Engine.AWBuggyIdle2'
	EngineRPMSoundRange=5000
	Wheels=/* Array type was not detected. */
	ExitPositions=/* Array type was not detected. */
	EntryPositions=/* Array type was not detected. */
	DrivePos=(X=0,Y=0,Z=80)
	bDrawDriverInTP=true
	FPCamPos=(X=0,Y=0,Z=180)
	TPCamLookat=(X=-100,Y=0,Z=140)
	TPCamDistance=700
	VehicleMass=8
	Mesh=SkeletalMesh'COGArmadilloAsset.Armadillo3'
	SoundRadius=255
	begin object name=KParams0 class=KarmaParamsRBFull
	// Object Offset:0x000727C4
	KInertiaTensor[0]=2
	KInertiaTensor[3]=10
	KInertiaTensor[5]=14
	KLinearDamping=0.05
	KAngularDamping=0.05
	KStartEnabled=true
	bKNonSphericalInertia=true
	bHighDetailOnly=false
	bClientOnly=false
	bKDoubleTickRate=true
	SafeTimeMode=2
	KFriction=0.5
object end
// Reference: KarmaParamsRBFull'Armadillo.KParams0'
KParams=KParams0
}