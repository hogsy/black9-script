class Explosive_Mine_Proximity_Proj extends B9Explosive_Proj
	placeable;


var float MotionRadius;
var float MotionSensitivity;

state Armed
{
	function BeginState()
	{
		// wait for collision
		SetCollision(true, true, true);
		SetCollisionSize(10.0f, 10.0f);
	}

	simulated function ProcessTouch( actor Other, vector HitLocation )
	{
		// nothing
	}

	simulated function Tick( float DeltaTime )
	{
		local Actor	other;


		Super.Tick(DeltaTime);

		ForEach RadiusActors( class'Actor', other, MotionRadius )
		{
			if(other != self)
			{
				if ( VSize( other.Velocity ) > MotionSensitivity )
				{
					Log( self $ " detected motion of " $ other $ ", velocity:" $ VSize( other.Velocity ) );
					Detonate();
					return;
				}
			}
		}
	}
}




defaultproperties
{
	MotionRadius=500
	MotionSensitivity=50
	BounceDamping=0.25
	fIniLookupName="ProxMine"
	DrawType=2
	Mesh=SkeletalMesh'B9Weapons_models.ProxMine_mesh'
}