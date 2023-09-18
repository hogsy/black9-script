// ====================================================================
//  Class:  MedicInfluence
//
//  The Medics heal 2 health every second
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class MedicInfluence extends Influence;

#exec OBJ LOAD FILE=..\Sounds\WarPickupSounds.uax

simulated function DrawInfluence(canvas C);

event Timer()
{

	local int i;
	local Pawn P;

	for (i=0;i<Touching.Length;i++)
	{
		p = Pawn(Touching[i]);
		if ( (P!=None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team==Pawn(Owner).PlayerReplicationInfo.Team) )
		{
			if (P.Health < P.Default.Health)
			{
				P.Health = Min(P.Health+5,P.Default.Health);
				P.PlaySound(sound 'MedicMinorHeal');
				if (PlayerController(P.Controller)!=None	 )
				{
//					PlayerController(P.Controller).ClientSetFlash(vect(0.019,0,0),vect(4.5,4.5,26.5));
				}
			}
		}
	}
	
	P = Pawn(Owner);

	if (P.Health < P.Default.Health)
	{	
		// Heal yourself
		P.Health = Min(P.Health+5,P.Default.Health);
		P.PlaySound(sound 'MedicMinorHeal');
		if (PlayerController(P.Controller)!=None	 )
		{
//			PlayerController(P.Controller).ClientSetFlash(vect(0.75,0,0),vect(0,0,64));
		}
	}
	
}

defaultproperties
{
	Range=640
}