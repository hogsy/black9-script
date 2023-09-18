// ====================================================================
//  Class:  WarClassLight.GeistGrunt
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarGeistGrunt extends GeistLightInfantry;

defaultproperties
{
	LandGrunt=Sound'MaleSounds.(All).land10'
	LoadOut=0
	RequiredEquipment[0]="WarClassLight.WeapCOGAssaultRifle"
	RequiredEquipment[1]="WarClassLight.WeapCOGPulse"
	RequiredEquipment[2]="WarClassLight.WarCogLightArmor"
	MenuName="Geist Grunt"
}