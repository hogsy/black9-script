class WarCOGPlasmaTrooper extends CogHeavyInfantry;

defaultproperties
{
	Helmet=StaticMesh'character_helmetmeshes.cog_helmets.CogShockHelmet1'
	LandGrunt=Sound'MaleSounds.(All).land10'
	RequiredEquipment[0]="WarClassHeavy.WeapCOGLightPlasma"
	RequiredEquipment[1]="WarClassHeavy.WarCogHeavyArmor"
	GroundSpeed=300
	WaterSpeed=300
	AirSpeed=300
	JumpZ=450
	Health=5
	MenuName="COG Shock Trooper"
	Mesh=SkeletalMesh'COGHeavySoldiers.COGShockMesh'
	CollisionRadius=50
	CollisionHeight=85
}