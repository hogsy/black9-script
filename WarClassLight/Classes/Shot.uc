class Shot extends WDamage
	abstract;

defaultproperties
{
	DeathString="%k riddled %o full of holes with the %w."
	DamageWeaponName="Enforcer"
	bInstantHit=true
	bFastInstantHit=true
	GibModifier=0.4
	LowDetailEffect=Class'WarEffects.BloodHit'
}