class GeistAPC extends SHalfTrack;

#exec OBJ LOAD FILE=..\animations\GeistAPCAsset.ukx

defaultproperties
{
	TrackInertia=0.1
	TrackLongSlip=0.001
	TrackLatSlipFunc=(Points=/* Array type was not detected. */,InVal=0,OutVal=0)
	TrackLongFrictionScale=0.7
	TrackLatFrictionScale=1.2
	TrackLinRatio=1
	MaxTrackBrakeTorque=10
	WheelSoftness=0.01
	WheelPenScale=1
	WheelInertia=0.1
	WheelLongFrictionFunc=(Points=/* Array type was not detected. */,InVal=0,OutVal=0)
	WheelLongSlip=0.001
	WheelLatSlipFunc=(Points=/* Array type was not detected. */,InVal=0,OutVal=0)
	WheelLongFrictionScale=0.7
	WheelLatFrictionScale=1.2
	WheelSuspensionTravel=25
	FTScale=0.03
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
	EngineBrakeFactor=0.0001
	EngineBrakeRPMScale=0.1
	SteerSpeed=110
	StopThreshold=100
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
	Mesh=SkeletalMesh'GeistAPCAsset.GeistAPCMesh2'
	SoundRadius=255
	begin object name=KParams0 class=KarmaParamsRBFull
	// Object Offset:0x000725D2
	KInertiaTensor[0]=3
	KInertiaTensor[3]=12
	KInertiaTensor[5]=12
	KCOMOffset=(X=0,Y=0,Z=1)
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
// Reference: KarmaParamsRBFull'GeistAPC.KParams0'
KParams=KParams0
}