class AmmoDepot extends Pickup
	abstract;

#exec OBJ LOAD FILE=..\Sounds\WarPickupSounds.uax
	
var byte Team;
var bool bLimited;		// Is this ammodepo limited to Uses # of uses 
var int Uses;			// How many times can it be used.		

var AmmoDepotBeacon MyBeacon;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	MyBeacon = Spawn(class 'AmmoDepotBeacon',self,,Location+(Vect(0,0,1)*64));
	if (MyBeacon!=None)
	{
		MyBeacon.Team = Team;
	}  

}


function float BotDesireability(Pawn P)
{
	if ( (P.PlayerReplicationInfo.Team == None)
		|| (P.PlayerReplicationInfo.Team.TeamIndex != Team) )
		return 0;

	if ( Bot(P.Controller) == None )
		return 0;

	if ( Bot(P.Controller).NeedAmmo() )
		return 1;
}

auto state Pickup
{
	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch( actor Other )
	{
		if ( (Pawn(Other) == None) || (Pawn(Other).PlayerReplicationInfo == None)
			|| (Pawn(Other).PlayerReplicationInfo.Team == None)
			|| (Pawn(Other).PlayerReplicationInfo.Team.TeamIndex != Team) 
			|| (Other == Owner) )
			return false;

		return Super.ValidTouch(Other);
	}

	// When touched by an actor.
	function Touch( actor Other )
	{
		local inventory inv;
		local bool bused;
		local Pawn P;

		
		// If touched by a player pawn, let him pick this up.
		if( ValidTouch(Other) )
		{
			bUsed = false;
			For ( Inv=Other.inventory; inv!=None; inv=inv.inventory )
				if ( Ammunition(Inv) != None )
				{
					Ammunition(Inv).AddAmmo(Ammunition(Inv).MaxAmmo);
					bUsed = true;
				}

			if ( bUsed )
			{

				P = Pawn(Other);
				if ( (P!=None) && (PlayerController(P.Controller) != None) )
				{
					PlayerController(P.Controller).ClientFlash(1.25,vect(0,128,0));
					if (WarfareWeapon(P.Weapon)!=None)
					{
						P.PlaySound(sound 'AmmoDepotUse');
					}
				}
				
			}
			Destroy();
		}
		
	
	}
}

event Landed(vector HitNormal)
{
	Super.Landed(HitNormal);
	Destroy();
}

defaultproperties
{
	Physics=2
	Mesh=VertMesh'Decorations.BarrelM'
	bObsolete=true
}