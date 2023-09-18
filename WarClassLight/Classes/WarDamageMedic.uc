// ====================================================================
//  Class:  WarClassLight.WarDamageMedic
//  Parent: WarfareGame.WarfareDamageType
//
//  <Enter a description here>
// ====================================================================

class WarDamageMedic extends WarfareDamageType;

defaultproperties
{
	DeathString="You just got your ass kicked by a nurse."
	DamageWeaponName="Medic Gun"
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