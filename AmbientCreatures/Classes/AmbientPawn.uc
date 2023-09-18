class AmbientPawn extends Pawn
	abstract;

function PlayCall();

/* PickSize()
Choose random size variation for this ambientpawn
*/
function PickSize(int NumKids, int NumMoms, int NumDads);

function bool IsFemale()
{
	return false;
}

function bool IsInfant()
{
	return false;
}

defaultproperties
{
	bAmbientCreature=true
}