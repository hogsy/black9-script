// ====================================================================
//  Class:  WarfareGame.WarDamageEngineerRay
//  Parent: WarfareGame.WarfareDamageType
//
//  <Enter a description here>
// ====================================================================

class WarDamageEngineerRay extends WarfareDamageType;

defaultproperties
{
	DeathString="Oh my god.. sparky the tech just beat you up!"
	DamageWeaponName="Engineer Gun"
	bArmorStops=false
	bInstantHit=true
	bFastInstantHit=true
	GibModifier=0.4
	PawnDamageEmitter=Class'WarEffects.WarBloodEffect'
	PawnDamageSounds=/* Array type was not detected. */
	LowDetailEffect=Class'WarEffects.BloodHit'
	DamageDesc=64
	DamageThreshold=15
	DamageKick=(X=256,Y=0,Z=256)
}