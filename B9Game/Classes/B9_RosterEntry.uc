class B9_RosterEntry extends Object
		editinlinenew;

var() class<B9_Pawn> PawnClass;
var() string PlayerName;
var() enum EOrders
{
	ORDERS_Attack,
	ORDERS_Defend,
	ORDERS_Freelance
} Orders;
var   byte SquadNumber;		// FIXME USE
var   bool bTaken;

var() class<Weapon> FavoriteWeapon;
var() float Aggressiveness;		// 0 to 1 (0.3 default, higher is more aggressive)
var() float Accuracy;			// -1 to 1 (0 is default, higher is more accurate)
var() float CombatStyle;		// 0 to 1 (0= stay back more, 1 = charge more)
var() float StrafingAbility;	// -1 to 1 (higher uses strafing more)

function bool RecommendDefense()
{
	return ( Orders == ORDERS_Defend );
}

function bool RecommendFreelance()
{
	return ( Orders == ORDERS_Freelance );
}

function InitBot(Bot B)
{
	B.FavoriteWeapon = FavoriteWeapon;
	B.Aggressiveness = FClamp(Aggressiveness, 0, 1);
	B.BaseAggressiveness = B.Aggressiveness;
	B.Accuracy = FClamp(Accuracy, -1, 1);
	B.StrafingAbility = FClamp(StrafingAbility, -1, 1);
	B.CombatStyle = FClamp(CombatStyle, 0, 1);
}

defaultproperties
{
	Aggressiveness=0.3
	CombatStyle=0.1
}