class Explosive_Mine_Pressure_Proj extends B9Explosive_Proj
	placeable;


state Armed
{
	function BeginState()
	{
		// wait for collision
		SetCollision(true, true, true);
		SetCollisionSize(40.0f, 15.0f);
	}

	event Bump( actor Other )
	{
		Log( self $ " stepped on by " $ other );
		Detonate();
	}

	simulated function ProcessTouch( actor Other, vector HitLocation )
	{
		if ( ( Other != instigator ) || bCanHitOwner )
		{
			Log( self $ " stepped on by " $ other );
			Detonate();
		}
	}
}
auto state Safe
{
	function BeginState()
	{
		SetTimer( FuseTime, false );
		SetCollision(true, true, true);
		SetCollisionSize(3.0f, 3.0f);
	}
}



defaultproperties
{
	BounceDamping=0.25
	fIniLookupName="Mine"
	DrawType=2
	Mesh=SkeletalMesh'B9Weapons_models.AntiPersonnelMine_mesh'
}