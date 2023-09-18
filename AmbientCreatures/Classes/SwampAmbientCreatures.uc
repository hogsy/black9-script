/*=============================================================================

 //SwampAmbientCreatures

 //AmbientCreatureManager for swamp terrain creatures

=============================================================================*/
class SwampAmbientCreatures extends AmbientCreatureManager;

var() int BugEscort;
var EscortBugs Escort;

// check if should spawn or destroy temporary ambient creatures
function Timer()
{
	Super.Timer();

	if ( (Escort == None) && (BugEscort > 0) && InSpawnRange() )
	{
		Escort = spawn(class'EscortBugs',self,,LocalPlayer.ViewTarget.Location);
		Escort.SetEscortSize(BugEscort-1);
	}
}

function RemoveCreature(TransientAmbientCreature Remove)
{
	if ( Remove == Escort )
		Escort = None;
	else
		super.RemoveCreature(Remove);
}

defaultproperties
{
	BugEscort=6
	TransientCreatures[0]=Class'FlyingBugs'
	TransientCreatures[1]=Class'WanderingBirds'
	TransientCreatures[2]=Class'FlyingBugs'
	SpawnRadius=10000
	TriggerRadius=12000
}