// ====================================================================
//  Class:  Influence
//
//  Influences can be thought of as runes or techs from other games.
//  They allow a given player class to Influence another class each tick.
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class Influence extends Info;

var float Range;			// How far out the bubble extends
var float Period;			// How often does it occure

function PostBeginPlay()
{

	if ( (Owner==None) || (Pawn(Owner)==None) )		// Influences must be owned by the player
	{
		log("Influence "$self$" has bad owner: "$Owner);
		Destroy();
		return;
	}		

	// Set the Collision info on the Influence so we can use Touch, UnTouch, and Touching 
	
	SetCollisionSize( Range, Owner.CollisionHeight);
	SetCollision( true, false, false);
	SetBase(Owner);
	
	// Say when the effect should occure
	
	SetTimer(Period,true);
}


event Timer();		// SHould be subclassed to perform the effect

defaultproperties
{
	Range=512
	Period=1
	bOnlyAffectPawns=true
}