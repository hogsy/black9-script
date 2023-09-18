// ====================================================================
//  Class:  WarfareGame.Constructions
//  Parent: Engine.Inventory
//
//  Constructions are things that players can create in the game.  
//  All players can purchase 1 shot deals or the Engineer can build things
//  nearly at will.
// ====================================================================

class Constructions extends Inventory;

var Constructions PendingConstruction;

var() class<WarfareStationaryWeapon> MyConstructClass;		// What this item builds
var() string ConstructionMessage;

var() bool bAlignToNormal;		// Should this item be aligned along the normal
var float XPos;	// Used for Animating it

replication
{
	reliable if (ROLE==Role_Authority)
		ClientAnimate;
		
	reliable if (ROLE<ROLE_Authority)
		ServerChange;
}

//
// Give this inventory item to a pawn.
//
function GiveTo( pawn Other )
{

	local WarfarePawn P;
	
	Super.GiveTo(Other);

	P = WarfarePawn(other);
	if (P!=None)
		P.AddConstruction(Self);				
}

function DropFrom(vector StartLocation)
{
	Destroy();
}

event Destroyed()
{
	local WarfarePawn P;
	P = WarfarePawn(Instigator);
	if (P!=None)
	  P.RemoveConstruction(Self);
}

function actor TraceHit(out vector HitLocation, out vector HitNormal,float distance)
{
	local vector StartTrace, EndTrace;
	local actor Other;

	StartTrace = Instigator.Location + Instigator.EyePosition(); 
	EndTrace = StartTrace + (Distance * Vector(Instigator.GetViewRotation()));
	Other = Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	return other;
}		

//=============================================================================
// Using - Perform a trace to see where to place the object and then spawn it there.

function Use( float Value )
{
	local vector HitLocation, HitNormal;
	local actor Other;
	local WarfareStationaryWeapon NewConstruct;

	if (WarfarePawn(Instigator).Energy >= MyConstructClass.Default.Cost)
	{ 
		Other = Tracehit(HitLocation, HitNormal,256);
		if ( (Other!=None) && (Other.bWorldGeometry) )
		{
			if (bAlignToNormal)
				NewConstruct = spawn(MyConstructClass,Instigator.Controller,,HitLocation, Rotator(HitNormal));
			else
			{
				hitlocation.Z+=5;
				NewConstruct = spawn(MyConstructClass,Instigator.Controller,,HitLocation);
			}

			if (NewConstruct!=None)
			{
				NewConstruct.SetTeam(Instigator.PlayerReplicationInfo.Team.TeamIndex);
				WarfarePawn(Instigator).Energy-= NewConstruct.Cost;
			}
			else
  				log("### Could not spawn construct");
		}
	}
	
	if (Charge>0)
	{
		Charge--;
		if (Charge==0)
		{
			Destroy();
		}
	}
}

function AltFire()
{
	Use(0);
}

function Next(Constructions C)
{
	PendingConstruction = C;
	ClientAnimate(1);
	if ( !Instigator.IsLocallyControlled() )
		GotoState('ServerWaiting');
}

function Prev(Constructions C)
{
	PendingConstruction = C;
	ClientAnimate(1);
	
	if ( !Instigator.IsLocallyControlled() )
		GotoState('ServerWaiting');
		
}

simulated Function ClientAnimate(int dir)
{

	if (dir==0)
		GotoState('ClientScrollIn');
	else
		GotoState('ClientScrollOut');
}

simulated function Update(float Delta);	


function ServerChange()
{

	WarfarePawn(Instigator).SelectedConstruction = PendingConstruction;
	if (PendingConstruction!=Self)
	{
		PendingConstruction.ClientAnimate(0);
		PendingConstruction.PendingConstruction = PendingConstruction;
		if ( !Instigator.IsLocallyControlled() )
			PendingConstruction.GotoState('ServerWaiting');
	}
	PendingConstruction = none;
	GotoState('');
}


state ServerWaiting
{
	function Use( float Value );
	function Next(Constructions C);
	function Prev(Constructions C);

}			 

simulated state ClientScrollIn
{

	simulated function Update(float Delta)
	{
		XPos += (128 * Delta);
		if (XPos>=5.0)
		{
			XPos = 5.0;
			GotoState('');
			ServerChange();
		}
	}
									
	simulated function BeginState()
	{
		XPos = -64.0;
	}
}
	
state ClientScrollOut
{

	simulated function Update(float Delta)
	{
		XPos -= (128 * Delta);
		if (XPos<=-64)
		{
			XPos = -64;
			GotoState('');
			ServerChange();
		}
	}
								
	simulated function BeginState()
	{
		XPos = 5.0;
	}
}

defaultproperties
{
	ConstructionMessage="Press [USE] to build"
	XPos=5
	AttachmentClass=none
}