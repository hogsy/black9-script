//=============================================================================
// BlitDagger_Ammunition
//
// This is an interesting class because the BlitDagger doesnt really
// require ammunition but this class is need to compile the weapon code
// 
//=============================================================================

class BlitDagger_Ammunition extends B9Ammunition;

simulated function bool HasAmmo()
{
	return true;
}

defaultproperties
{
	fIniLookupName="BlitDagger"
	MaxAmmo=1
	AmmoAmount=1
	RefireRate=1.5
	ItemName="BlitDagger"
}