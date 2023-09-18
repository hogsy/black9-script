class Vehicle extends Pawn
    native
    abstract;
    
var() byte Team;
var bool bDefensive; // should be used by defenders

// generic controls (set by controller, used by concrete derived classes)
var (KVehicle) float    Steering; // between -1 and 1
var (KVehicle) float    Throttle; // between -1 and 1


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if ( !bDeleteMe )
		Level.Game.RegisterVehicle(self);
}

// AI code
function bool Occupied()
{
	return ( Controller != None );
}

function Actor GetBestEntry(Pawn P)
{
	return self;
}

defaultproperties
{
	Team=255
}