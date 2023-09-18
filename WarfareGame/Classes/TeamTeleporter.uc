// ====================================================================
//  Class:  WarfareGame.TeamTeleporter
//
//  A Teleporter that's locked to a given team.  You can also trigger
//  this teleporter and have it switch to the team of the player who
//  triggered it.
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class TeamTeleporter extends Teleporter;

var() int TeamIndex;						// Who can use it.
var() class<Effects> TEffectClass;			// The Effect to use
var Effects TEffect;						// Holds the Effect


// If someone triggers this Teleporter, switch it to his team/

event Trigger( Actor Other, Pawn EventInstigator )
{
	TeamIndex = EventInstigator.PlayerReplicationInfo.Team.TeamIndex;
}

simulated function Destroyed()
{
	if ( TEffect != None )
		TEffect.Destroy();
		
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	local class<Effects> TEffectClass;

	LoopAnim('Teleport', 2.0, 0.0);
	
	if (TEffectClass!=None)
	{
		TEffect = spawn(TEffectClass);
		TEffect.lifespan = 0.0;
	}
	
	Super.PostBeginPlay();
}

// Teleporter was touched by an actor, check his team and cull out if needed

simulated function Touch( actor Other )
{
	local pawn P;
	
	P = Pawn(Other);
	if (P!=None && P.PlayerReplicationInfo.Team.TeamIndex != TeamIndex)
		return;
	
	Super.Touch(Other);
}		

defaultproperties
{
	TeamIndex=255
	TEffectClass=Class'WarEffects.UTTeleEffect'
	DrawType=2
	bStatic=false
	bHidden=false
	Mesh=VertMesh'WarEffects.Tele2'
	Style=3
	bUnlit=true
	bObsolete=true
}