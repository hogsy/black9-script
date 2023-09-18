class KRepulsor extends Actor
	native;

var()	bool	bEnableRepulsion;
var()	vector	CheckDir; // In owner ref frame
var()	float	CheckDist;
var()	float	Softness;
var()	float	PenScale;

// Used internally for Karma stuff - DO NOT CHANGE!
var		transient const int		KContact;  

defaultproperties
{
	CheckDir=(X=0,Y=0,Z=-1)
	CheckDist=50
	Softness=0.1
	PenScale=1
	RemoteRole=0
	bHardAttach=true
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false
}