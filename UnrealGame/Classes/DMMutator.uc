//=============================================================================
// DMMutator.
//=============================================================================

class DMMutator extends Mutator
	config;

var() globalconfig bool bMegaSpeed;
var() globalconfig float AirControl;

// mc - localized PlayInfo descriptions & extra info
var private localized string DMMutPropsDisplayText[2];

function bool MutatorIsAllowed()
{
	return true;
}

function bool AlwaysKeep(Actor Other)
{
	if ( NextMutator != None )
		return ( NextMutator.AlwaysKeep(Other) );
	return false;
}

function ModifyPlayer(Pawn Other)
{
	Other.AirControl = AirControl;
	Other.AirControl = AirControl;
	Other.bAutoActivate = true;
	if ( bMegaSpeed )
	{
		Other.GroundSpeed = 1.4 * Other.Default.GroundSpeed;
		Other.WaterSpeed = 1.4 * Other.Default.WaterSpeed;
		Other.AirSpeed = 1.4 * Other.Default.AirSpeed;
		Other.AccelRate = 1.4 * Other.Default.AccelRate;
	}
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

defaultproperties
{
	AirControl=0.35
	DMMutPropsDisplayText[0]="Mega Speed"
	DMMutPropsDisplayText[1]="Air Control"
}