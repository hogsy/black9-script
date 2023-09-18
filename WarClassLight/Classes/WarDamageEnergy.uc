// ====================================================================
//  Class:  WarClassLight.WarDamageEnergy
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarDamageEnergy extends WarfareDamageType;


defaultproperties
{
	DeathString="%k fried %o."
	DamageWeaponName="Energy"
	bInstantHit=true
	bFastInstantHit=true
	GibModifier=0.4
	PawnDamageEmitter=Class'WarEffects.WarBloodEffect'
	PawnDamageSounds=/* Array type was not detected. */
	LowDetailEffect=Class'WarEffects.BloodHit'
	DamageDesc=18
}