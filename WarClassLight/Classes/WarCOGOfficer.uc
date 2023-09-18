//=============================================================================
// WarCogOfficer.
//=============================================================================
class WarCogOfficer extends CogLightInfantry;

defaultproperties
{
	Helmet=StaticMesh'character_helmetmeshes.cog_helmets.COGGruntHelmet1b'
	LandGrunt=Sound'MaleSounds.(All).land10'
	RequiredEquipment[0]="WarClassLight.WeapCOGAssaultRifle"
	RequiredEquipment[1]="WarClassLight.WeapCOGPulse"
	RequiredEquipment[2]="WarClassLight.WarCogLightArmor"
	MenuName="COG Officer"
}