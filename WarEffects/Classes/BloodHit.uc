//=============================================================================
// BloodHit.
// put a splat on the wall 
//=============================================================================
class BloodHit extends Blood;

simulated function PostNetBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
		WallSplat();
}

simulated function WallSplat()
{
	local vector WallHit, WallNormal;
	local Actor WallActor;

	WallActor = Trace(WallHit, WallNormal, Location + 300 * vector(Rotation), Location, false);
//	if ( WallActor != None )	
//		spawn(class'BloodSplat',,,WallHit + 20 * (WallNormal + VRand()), rotator(WallNormal));
//!! BloodSplat class removed.
}

