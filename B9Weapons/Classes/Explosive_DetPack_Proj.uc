class Explosive_DetPack_Proj extends B9Explosive_Proj;



simulated function HitWall( vector HitNormal, actor Wall )
{
	// stick to this object
	Velocity	= vect( 0, 0, 0 );
	Super.HitWall( HitNormal, Wall );
}

simulated function Detonate()
{
	local Explosive_DetPack	chrg;
	local Inventory		Inv;

	Super.Detonate();

	for( Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory )
	{
		chrg = Explosive_DetPack( Inv );
		if( chrg != none )
		{
			chrg.UpdateAmmoCount();
			break;
		}
	}

}

defaultproperties
{
	FuseTime=600
	BounceDamping=0.25
	fIniLookupName="DetPack"
	ImpactSound=none
	DrawType=2
	Mesh=SkeletalMesh'B9Weapons_models.DetPack_mesh'
}