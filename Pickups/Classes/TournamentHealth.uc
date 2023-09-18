class TournamentHealth extends WarfarePickUp
	abstract;

var() int HealingAmount;
var() bool bSuperHeal;

function float BotDesireability(Pawn Bot)
{
	local float desire;
	local int HealMax;

	HealMax = Bot.Default.Health;
	if (bSuperHeal) HealMax = Min(199, HealMax * 2.0);
	desire = Min(HealingAmount, HealMax - Bot.Health);

	if ( (Bot.Weapon != None) && (Bot.Weapon.AIRating > 0.5) )
		desire *= 1.7;
	if ( Bot.Health < 45 )
		return ( FMin(0.03 * desire, 2.2) );
	else
	{
		if ( desire > 6 )
			desire = FMax(desire,25);
		return ( FMin(0.017 * desire, 2.0) ); 
	}
}

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.PickupMessage$Default.HealingAmount;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return ClipY - YL - (64.0/768)*ClipY;
}

auto state Pickup
{	
	function Touch( actor Other )
	{
		local int HealMax;
		local Pawn P;
			
		if ( ValidTouch(Other) ) 
		{	
			P = Pawn(Other);	
			HealMax = P.default.health;
			if (bSuperHeal) HealMax = Min(199, HealMax * 2.0);
			if (P.Health < HealMax) 
			{
				AnnouncePickup(P);
				P.Health = Min(HealMax, P.Health + HealingAmount);
			}
		}
	}
}

defaultproperties
{
	HealingAmount=20
	MaxDesireability=0.5
	RespawnTime=20
	PickupMessage="You picked up a Health Pack +"
	PickupSound=Sound'WarEffects.Pickups.Health2'
	AmbientGlow=64
	CollisionHeight=8
	Mass=10
}