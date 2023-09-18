// ====================================================================
//  Class:  WarClassLight.WarDamageExplosion
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarDamageExplosion extends WarfareDamageType;

#exec OBJ LOAD FILE=..\Sounds\BulletSounds.uax PACKAGE=BulletSounds

defaultproperties
{
	DeathString="%k immolated %o."
	DamageWeaponName="Explosion"
	bInstantHit=true
	bFastInstantHit=true
	GibModifier=0.4
	PawnDamageEmitter=Class'WarEffects.WarBloodEffect'
	PawnDamageSounds=/* Array type was not detected. */
	LowDetailEffect=Class'WarEffects.BloodHit'
	DamageDesc=20
}