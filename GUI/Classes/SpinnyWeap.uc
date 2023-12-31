// Used for weapons page

class SpinnyWeap extends Actor;

var() int SpinRate;

var()	bool			bPlayRandomAnims;
var()	float			AnimChangeInterval;
var()	array<name>		AnimNames;

var		float			CurrentTime;
var		float			NextAnimTime;

function Tick(float Delta)
{
	local rotator NewRot;

	NewRot = Rotation;
	NewRot.Yaw += Delta * SpinRate;
	SetRotation(NewRot);

	CurrentTime += Delta;

	// If desired, play some random animations
	if(bPlayRandomAnims && CurrentTime >= NextAnimTime)
	{
		PlayNextAnim();
	}
}

function PlayNextAnim()
{
	local name NewAnimName;

	if(Mesh == None || AnimNames.Length == 0)
		return;

	NewAnimName = AnimNames[Rand(AnimNames.Length)];
	PlayAnim(NewAnimName, 1.0, 0.25); 

	NextAnimTime = CurrentTime + AnimChangeInterval;
}

defaultproperties
{
	spinRate=20000
	AnimChangeInterval=3
	AnimNames=/* Array type was not detected. */
	DrawType=8
	RemoteRole=0
	LODBias=100000
	DrawScale=0.5
	bUnlit=true
	bAlwaysTick=true
}