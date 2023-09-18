class Drowned extends DamageType
	abstract;

static function class<Effects> GetPawnDamageEffect( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	return Default.PawnDamageEffect;
}

defaultproperties
{
	DeathString="%o forgot to come up for air."
	FemaleSuicide="%o forgot to come up for air."
	MaleSuicide="%o forgot to come up for air."
	bArmorStops=false
	bNoSpecificLocation=true
	bCausesBlood=false
	FlashFog=(X=312.5,Y=468.75,Z=468.75)
}