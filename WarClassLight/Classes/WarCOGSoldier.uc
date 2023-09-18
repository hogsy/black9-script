//=============================================================================
// WarCogSoldier.
//=============================================================================
class WarCogSoldier extends CogLightInfantry;

defaultproperties
{
	LandGrunt=Sound'MaleSounds.(All).land10'
	RequiredEquipment[0]="WarClassLight.WeapCOGAssaultRifle"
	RequiredEquipment[1]="WarClassLight.WeapCOGPulse"
	RequiredEquipment[2]="WarClassLight.WarCogLightArmor"
	RagdollOverride="soldier2"
	MenuName="Soldier"
}