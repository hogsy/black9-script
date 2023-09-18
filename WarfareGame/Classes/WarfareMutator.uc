// ====================================================================
//  Class:  WarfareGame.WarfareMutator
//  Parent: UnrealGame.DMMutator
//
//  <Enter a description here>
// ====================================================================

class WarfareMutator extends DMMutator;

function PlayerChangedClass(Controller aPlayer)	// Should be subclassed
{
	local WarfareStationaryWeapon W;

	foreach AllActors(class 'WarfareStationaryWeapon', W)
	{
		if (W.Owner == aPlayer)	// Destroy all Stationary Weapons belonging to this player
			W.Explode(W.Location,vect(0,0,0));
	}
}

