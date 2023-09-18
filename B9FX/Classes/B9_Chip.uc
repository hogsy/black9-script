//=============================================================================
// B9_Chip.
//=============================================================================
class B9_Chip extends Effects;

var bool bHasBounced;

auto state Flying
{
	simulated function HitWall( vector HitNormal, actor Wall )
	{
		local vector RealHitNormal;
	
		if ( bHasBounced && ((FRand() < 0.85) || (Velocity.Z > -50)) )
			bBounce = false;
		RealHitNormal = HitNormal;
		HitNormal = Normal(HitNormal + 0.4 * VRand());
		if ( (HitNormal Dot RealHitNormal) < 0 )
			HitNormal *= -0.5; 
		Velocity = 0.5 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
		RotationRate.Yaw = 100000 * 2 *FRand() - 100000;
		RotationRate.Pitch = 100000 * 2 *FRand() - 100000;
		RotationRate.Roll = 100000 * 2 *FRand() - 100000;	
		DesiredRotation = RotRand();		
		bHasBounced = True;
	}

	simulated function Landed( vector HitNormal )
	{
		local rotator RandRot;	

		SetPhysics(PHYS_None);
		RandRot = Rotation;
		RandRot.Pitch = 0;
		RandRot.Roll = 0;
		SetRotation(RandRot);
	}

	simulated function BeginState()
	{
		if (FRand()<0.25) PlayAnim('Position1');
		else if (FRand()<0.25) PlayAnim('Position2');
		else if (FRand()<0.25) PlayAnim('Position3');
		else PlayAnim('Position4');	
		Velocity = VRand()*200*FRand()+Vector(Rotation)*250;
		DesiredRotation = RotRand();		
		RotationRate.Yaw = 200000 * 2 *FRand() - 200000;
		RotationRate.Pitch = 200000 * 2 *FRand() - 200000;
		RotationRate.Roll = 200000 * 2 *FRand() - 200000;			
		SetDrawScale(FRand()*0.4 + 0.3);
	}
}

defaultproperties
{
	Physics=2
	DrawType=2
	RemoteRole=2
	LifeSpan=3
	bCollideWorld=true
	bBounce=true
	bFixedRotationDir=true
}