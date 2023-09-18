class DOMTeamAI extends TeamAI;

var SquadAI PrimaryDefender;

function bool DominationPending()
{
	local GameObjective O;

	for ( O=Objectives; O!=None; O=O.NextObjective )
		if ( (O.DefenderTeamIndex == Team.TeamIndex) || (O.DefenderTeamIndex == 255) )
			return false;
	return true;
}

function CheckFreelanceObjective(SquadAI S)
{
	local GameObjective O, Best;
	
	if ( (S.SquadObjective != None) 
		&& ((S.SquadObjective.DefenderTeamIndex != Team.TeamIndex) || DominationPending()) )
		return;

	// check if any unowned objectives
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (DominationPoint(O) != None)
			&& ((Best == None) || (Best.DefenderTeamIndex == Team.TeamIndex)) )
			Best = O;
	}
	if ( Best != S.SquadObjective )
	{
		S.SquadObjective = Best;
		S.SetFinalStretch(false);
	}
}

function bool StayFreelance(SquadAI S)
{
	if ( (S.SquadObjective != None) 
		&& ((S.SquadObjective.DefenderTeamIndex != Team.TeamIndex) || DominationPending()) )
		return false;
	
	return (  (S.SquadObjective == None) || (S.SquadObjective.DefenderTeamIndex == Team.TeamIndex) ); 
}		

function bool PutOnDefense(Bot B)
{
	local GameObjective O;

	O = GetLeastDefendedObjective();
	if ( O != None )
	{
		if ( PrimaryDefender == None )
			PrimaryDefender = AddSquadWithLeader(B, O);
		else
			PrimaryDefender.AddBot(B);
		return true;
	}
	return false;
}

/* FindNewObjectiveFor()
pick a new objective for a squad that has completed its current objective
*/
function FindNewObjectiveFor(SquadAI S, bool bForceUpdate)
{
	local GameObjective O;
	
	if ( PlayerController(S.SquadLeader) != None )
		return;
	if ( S.bFreelance )
		O = GetPriorityFreelanceObjective();
	else if ( S.SquadObjective != None )	
		O = S.SquadObjective;
	else if ( S.GetOrders() == 'Attack' )
		O = GetPriorityAttackObjective();
	if ( O == None )
		O = GetLeastDefendedObjective();
	S.SetObjective(O, bForceUpdate);
}

function GameObjective GetLeastDefendedObjective()
{
	local GameObjective O, Best;

	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (DominationPoint(O) != None) && DominationPoint(O).CheckPrimaryTeam(Team.TeamIndex)
			&& ((Best == None) || (Best.DefensePriority	< O.DefensePriority)
				|| ((Best.DefensePriority == O.DefensePriority) && (Best.GetNumDefenders() < O.GetNumDefenders()))) )
			Best = O;
	}
	return Best;
}

function GameObjective GetPriorityAttackObjective()
{
	local GameObjective O, Best;

	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (DominationPoint(O) != None) && !DominationPoint(O).CheckPrimaryTeam(Team.TeamIndex)
			&& ((Best == None) || (Best.DefenderTeamIndex == Team.TeamIndex)) )
			Best = O;
	}
	return Best;
}

function GameObjective GetPriorityFreelanceObjective()
{
	local GameObjective O, Best;
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( (DominationPoint(O) != None)
			&& ((Best == None) || (Best.DefenderTeamIndex == Team.TeamIndex)) )
			Best = O;
	}
	return Best;
}

function SetObjectiveLists()
{
	local GameObjective O;
	local bool bAlt;
	
	ForEach AllActors(class'GameObjective',O)
		if ( O.bFirstObjective )
		{
			Objectives = O;
			break;
		}
	for ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( DominationPoint(O) != None )
		{
			if ( bAlt )
				DominationPoint(O).PrimaryTeam = 0;
			else
				DominationPoint(O).PrimaryTeam = 1;
			bAlt = !bAlt;
		}
	}
}

function SetBotOrders(Bot NewBot, RosterEntry R)
{
	if ( Team.Size == 1 )
		OrderList[0] = 'FREELANCE';
		
	Super.SetBotOrders(NewBot,R);
}

function SetOrders(Bot B, name NewOrders, Controller OrderGiver)
{
	local GameObjective O, Best;
	local SquadAI S;
	local float BestDist;

	if ( (NewOrders == 'HOLD') && (PlayerController(OrderGiver) != None) )
	{
		BestDist = 2000;
		for ( O=Objectives; O!=None; O=O.NextObjective )
			if ( (VSize(PlayerController(OrderGiver).ViewTarget.Location - O.Location) < BestDist) && OrderGiver.LineOfSightTo(O) )
			{
				Best = O;
				BestDist = VSize(PlayerController(OrderGiver).ViewTarget.Location - O.Location);
			} 
			if ( Best != None )
			{
				if ( B.Squad.SquadObjective != Best )
				{
					for ( S=Squads; S!=None; S=S.NextSquad )
						if ( (S.SquadObjective == Best) && (PlayerController(S.SquadLeader) == None) )
						{
							S.AddBot(B);
							return;
						}
					AddSquadWithLeader(B, Best);
					return;
				}
			}
	}
	
	Super.SetOrders(B,NewOrders,OrderGiver);
}

defaultproperties
{
	SquadType=Class'DOMSquadAI'
	OrderList[0]=attack
	OrderList[1]=Defend
	OrderList[2]=attack
	OrderList[4]=Defend
	OrderList[6]=Freelance
}