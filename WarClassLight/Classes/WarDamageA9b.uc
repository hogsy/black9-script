// ====================================================================
//  Class:  WarClassLight.WarA9
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarDamageA9b extends WarfareDamageType;

#exec OBJ LOAD FILE=..\Sounds\BulletSounds.uax PACKAGE=BulletSounds

defaultproperties
{
	DeathString="%k ripped %o full of holes with the %w."
	DamageWeaponName="Assault Rifle"
	bInstantHit=true
	bFastInstantHit=true
	GibModifier=0.4
	PawnDamageEmitter=Class'WarEffects.WarBloodEffect'
	PawnDamageSounds=/* Array type was not detected. */
	LowDetailEffect=Class'WarEffects.BloodHit'
	DamageDesc=2
	DamageThreshold=15
	DamageKick=(X=512,Y=0,Z=512)
}