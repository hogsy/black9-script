class PockStrip extends Keypoint;

var() float StripDistance;
var() float PockTime;
var() float Randomize;
var() int   NumPocks;
var int StartPocks;
var vector FireDir,FireStart,LineDir;
var() class<Emitter> WallEffect,BloodEffect;
var() bool bSprayRight;

function Trigger(actor Other, pawn EventInstigator)
{
	GotoState('Shooting');
}

state Shooting
{
	function BeginState()
	{
		NumPocks = Max(NumPocks,1);
		StartPocks = NumPocks;
		FireDir = vector(Rotation);
		LineDir = Normal(FireDir cross vect(0,0,1)) * StripDistance/NumPocks;
		if ( bSprayRight )
			LineDir *= -1;
		FireStart = Location;
		SetTimer(PockTime,true);
		Timer();
	}

	function Timer()
	{
		local vector HitNormal,HitLocation, RandOffset;
		local actor HitActor;

		RandOffset = Randomize * VRand();
		HitActor = Trace(HitLocation, HitNormal, FireStart + 5000*FireDir + RandOffset, FireStart + RandOffset, false);
		if ( HitActor != None )
		{
			if( (HitActor.bWorldGeometry || (Mover(HitActor) != None)) && (WallEffect != None) )
				spawn(WallEffect,,,HitLocation+HitNormal,rotator(HitNormal));
			if ( (Pawn(HitActor) != None) && (BloodEffect != None) )
				spawn(BloodEffect,,,HitLocation+HitNormal,rotator(HitNormal));
		}

		FireStart += LineDir;
		NumPocks--;
		if ( NumPocks == 0 )
		{
			NumPocks = StartPocks;
			GotoState('');
		}
	}
}

defaultproperties
{
	StripDistance=300
	PockTime=0.05
	Randomize=40
	NumPocks=20
	WallEffect=Class'WarfareGame.WarBulletHitsWall'
	bSprayRight=true
	bStatic=false
	bDirectional=true
}