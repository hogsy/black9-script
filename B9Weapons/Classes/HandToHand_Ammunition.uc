//=============================================================================
// HandToHand_Ammunition
//
// This is an interesting class because the HandToHand doesnt really
// require ammunition but this class is need to compile the weapon code
// 
//=============================================================================

class HandToHand_Ammunition extends B9Ammunition;

simulated function bool HasAmmo()
{
	return true;
}

defaultproperties
{
	fIniLookupName="Fist"
	MaxAmmo=1
	AmmoAmount=1
	RefireRate=1.5
	ItemName="HandToHand"
}