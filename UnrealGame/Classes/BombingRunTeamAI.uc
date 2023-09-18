class BombingRunTeamAI extends TeamAI;

var CarriedObject Bomb; 
var float LastGotFlag;
var GameObjective HomeBase, EnemyBase, BombBase;

function SetObjectiveLists()
{
	local GameObjective O;

	ForEach AllActors(class'GameObjective',O)
		if ( O.bFirstObjective )
		{
			Objectives = O;
			break;
		}
		
	For ( O=Objectives; O!=None; O=O.NextObjective )
	{
		if ( O.DefenderTeamIndex == 255 )
			BombBase = O;
		else if ( O.DefenderTeamIndex == Team.TeamIndex )
			HomeBase = O;
		else
			EnemyBase = O;
	}
}

function SquadAI AddSquadWithLeader(Controller C, GameObjective O)
{
	local BombingRunSquadAI S;

	if ( O == None )
		O = EnemyBase;
	S = BombingRunSquadAI(Super.AddSquadWithLeader(C,O));
	S.Bomb = Bomb;
	S.HomeBase = HomeBase;
	S.EnemyBase = EnemyBase;
	S.BombBase = BombBase;
	return S;
}

defaultproperties
{
	SquadType=Class'BombingRunSquadAI'
	OrderList[0]=attack
	OrderList[3]=attack
	OrderList[4]=Freelance
	OrderList[5]=Defend
	OrderList[6]=attack
	OrderList[7]=Defend
}