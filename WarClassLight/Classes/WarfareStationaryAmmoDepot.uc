// ====================================================================
//  Class:  WarClassLight.WarfareStationaryAmmoDepot
//  Parent: WarfareGame.WarfareStationaryWeapon
//
//  <Enter a description here>
// ====================================================================

class WarfareStationaryAmmoDepot extends WarfareStationaryWeapon;

//#EXEC OBJ LOAD FILE=..\StaticMeshes\AMMOdispencers.usx PACKAGE=AMMOdispencers
//#EXEC OBJ LOAD FILE=..\StaticMeshes\StationaryWeapons_M.usx PACKAGE=StationaryWeapons_M
#EXEC OBJ LOAD FILE=..\StaticMeshes\DeployedItems.usx PACKAGE=DeployedItems

var AmmoDepotBeacon MyBeacon;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	MyBeacon = Spawn(class 'AmmoDepotBeacon',self,,Location+(Vect(0,0,1)*64));
	if (MyBeacon!=None)
		MyBeacon.Team = TeamIndex;

}

function SetTeam(int NewTeamIndex)
{
	if (MyBeacon!=None)
		MyBeacon.Team = NewTeamIndex;
		
	Super.SetTeam(NewTeamIndex);
}
	

event Destroyed()
{
	if (MyBeacon!=None)
		MyBeacon.Destroy();
}

function float BotDesireability(Pawn P)
{
	if ( (P.PlayerReplicationInfo.Team == None)
		|| (P.PlayerReplicationInfo.Team.TeamIndex != TeamIndex) )
		return 0;

	if ( Bot(P.Controller) == None )
		return 0;

	if ( Bot(P.Controller).NeedAmmo() )
		return 1;
}

function Touch( actor Other );

function SpawnBrokenEffect()
{
	Spawn(class 'PclSparks',,,location+vect(0,0,8),rotation);
}


auto state Online
{
	/* ValidTouch()
	 Validate touch (if valid return true to let other pick me up and trigger event).
	*/
	function bool ValidTouch( actor Other )
	{
		if ( (Pawn(Other) == None) || (Pawn(Other).PlayerReplicationInfo == None)
			|| (Pawn(Other).PlayerReplicationInfo.Team == None)
			|| (Pawn(Other).PlayerReplicationInfo.Team.TeamIndex != TeamIndex) )
			return false;
			
		return true;
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
				
				GotoState('Waiting');

			}

		}
	
	}
}

state Waiting
{

	function Touch( actor Other );

	event Timer()
	{
		GotoState('Online');
	}
	
	function BeginState()
	{
		SetTimer(1.0,false);
	}
		
}

defaultproperties
{
	Health=250
	cost=60
	Meshes[0]=StaticMesh'DeployedItems.AmmoDepot.C_M_AmmoDepot_SG'
	Meshes[1]=StaticMesh'DeployedItems.AmmoDepot.G_M_AmmoDepot_SG'
	DrawScale=0.33
	CollisionRadius=64
	CollisionHeight=8
}