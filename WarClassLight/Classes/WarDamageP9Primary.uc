class WarDamageP9Primary extends WarfareDamageType;


defaultproperties
{
	DeathString="%k ripped %o full of holes with the %w."
	DamageWeaponName="Assault Rifle"
	bArmorStops=false
	bInstantHit=true
	bFastInstantHit=true
	GibModifier=0.4
	PawnDamageEmitter=Class'WarEffects.WarBloodEffect'
	PawnDamageSounds=/* Array type was not detected. */
	LowDetailEffect=Class'WarEffects.BloodHit'
	DamageDesc=36
	DamageThreshold=15
	DamageKick=(X=256,Y=0,Z=256)
}