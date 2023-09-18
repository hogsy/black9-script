//=============================================================================
// Tazer_Ammunition
//
// This is an interesting class because the Tazer doesnt really
// require ammunition but this class is need to compile the weapon code
// 
//=============================================================================

class Tazer_Ammunition extends Ammunition;

simulated function bool HasAmmo()
{
	return true;
}

defaultproperties
{
	MaxAmmo=1
	AmmoAmount=1
	RefireRate=1.5
	ItemName="Tazer"
}