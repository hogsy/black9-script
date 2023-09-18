class CTFTeamAI extends TeamAI;

var CTFFlag FriendlyFlag, EnemyFlag; 
var float LastGotFlag;

function SquadAI AddSquadWithLeader(Controller C, GameObjective O)
{
	local CTFSquadAI S;

	if ( O == None )
		O = EnemyFlag.HomeBase;
	S = CTFSquadAI(Super.AddSquadWithLeader(C,O));
	if ( S != None )
	{
		S.FriendlyFlag = FriendlyFlag;
		S.EnemyFlag = EnemyFlag;
	}
	return S;
}

defaultproperties
{
	SquadType=Class'CTFSquadAI'
	OrderList[0]=attack
	OrderList[1]=Defend
	OrderList[2]=attack
	OrderList[3]=attack
	OrderList[4]=Defend
	OrderList[5]=Freelance
	OrderList[6]=attack
	OrderList[7]=attack
}