class WarCOGSniper extends CogLightInfantry;
#exec OBJ LOAD FILE=..\Textures\sg_Hud.utx PACKAGE=SG_Hud

defaultproperties
{
	LandGrunt=Sound'MaleSounds.(All).land10'
	ClassIcon=Texture'SG_Hud.COG.sg_classicons_sniper'
	RequiredEquipment[0]="WarClassLight.WeapGeistSniperRifle"
	RequiredEquipment[1]="WarClassLight.WeapCOGPulse"
	RequiredEquipment[2]="WarClassLight.WarCogLightArmor"
	AttackSuitability=0.1
	MenuName="COG Sniper"
}