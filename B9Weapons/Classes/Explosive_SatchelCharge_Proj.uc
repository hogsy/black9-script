class Explosive_SatchelCharge_Proj extends B9Explosive_Proj;




simulated function Detonate()
{
	local Explosive_SatchelCharge	chrg;
	local Inventory		Inv;

	log( "### Explosive_SatchelCharge_Proj::Detonate()" );

	Super.Detonate();

	for( Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory )
	{
		chrg = Explosive_SatchelCharge( Inv );
		if( chrg != none )
		{
			log( "### Explosive_SatchelCharge_Proj::Detonate() -- found item to remove ammo count from" );

			chrg.UpdateAmmoCount();
			break;
		}
	}

}

defaultproperties
{
	FuseTime=600
	BounceDamping=0.25
	fIniLookupName="SatchelCharge"
	DrawType=2
	Mesh=SkeletalMesh'B9Weapons_models.SatchelCharge_mesh'
}