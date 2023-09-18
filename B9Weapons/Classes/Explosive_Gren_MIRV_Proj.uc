class Explosive_Gren_MIRV_Proj extends B9Explosive_Proj;




simulated function Explode(vector HitLocation, vector HitNormal)
{
	// Just go away
	Destroy();
}


function FireSubmunitions()
{
	local rotator Dir;
	local int subminitionNumber;


	for( subminitionNumber = 0; subminitionNumber < 4; subminitionNumber++ )
	{
		Dir.pitch = Rand(65535);
		Dir.roll = Rand(65535);
		Dir.yaw = Rand(65535);
		
		Spawn( class'Explosive_Gren_MIRV_Submunition_Proj',,, Location,Dir );
	}


	Destroy();
}


state Armed
{
	function BeginState()
	{
		FireSubmunitions();
	}
}


defaultproperties
{
	BounceDamping=0.65
	DrawType=2
	Mesh=SkeletalMesh'B9Weapons_models.ClusterBomb_mesh'
}