//=============================================================================
// proj_HeavyRocket.uc
//=============================================================================
class proj_Flamethrower extends B9ProjectileBase;



simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode == NM_Client )
	{
		LifeSpan = 1.0;
	}
	else
	{
		Velocity = Speed * vector(Rotation);
		OrientProjectile(Instigator);
	}

	if ( Level.bDropDetail )
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
}



simulated function HitWall( vector HitNormal, actor Wall )
{
	Velocity.X = 0;
	Velocity.Y = 0;
	Velocity.Z = 0;
}


simulated function Explode(vector HitLocation, vector HitNormal)
{	
 	Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	//local Emitter	fx;
	
	if( Other == Instigator && Lifespan > 0.9 )
	{
		return;
	}

	if ( Role == ROLE_Authority )
	{
		Other.TakeDamage( Damage, instigator, HitLocation, MomentumTransfer*Vector(Rotation), MyDamageType);
		//fx = spawn( class'HitFX_Flamethrower_Emitter',,,Other.Location );
		//fx.SetOwner( Other );
		//fx.SetBase( Other );
	}
	
	Explode(HitLocation, vect(0,0,1));

}


defaultproperties
{
	Speed=1300
	MaxSpeed=1300
	Damage=1
	MomentumTransfer=10000
	MyDamageType=Class'B9BasicTypes.damage_FlameThrower'
	LightType=4
	LightEffect=13
	LightBrightness=200
	LightRadius=10
	LightHue=28
	LightSaturation=32
	DrawType=0
	bDynamicLight=true
	LifeSpan=1
	CollisionRadius=40
	CollisionHeight=40
	bFixedRotationDir=true
	ForceType=1
	ForceRadius=100
	ForceScale=0.7
}