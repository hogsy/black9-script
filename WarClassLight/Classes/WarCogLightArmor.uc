// ====================================================================
//  Class:  WarClassLight.WarCogLightArmor
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarCogLightArmor extends WarfareArmor;

#exec OBJ LOAD FILE=..\Sounds\BulletSounds.uax PACKAGE=BulletSounds

var sound Impacts[3];

function int ArmorAbsorbDamage(int Damage, class<DamageType> DamageType, vector HitLocation)
{
	local int ArmorDamage;

	if ( (!CanStop(DamageType) ) || (Charge == 0) )	
		return Damage;

	if (DamageType.static.IsOfType(DAMAGE_ArmorKiller) )	// Handle Armor killers first
	{
		Charge = Clamp(Charge-15,0,Charge);
		return 1;
	}	
		
	ArmorEffect(Damage, DamageType, HitLocation);

	if (DamageType.static.IsOfType(DAMAGE_Light) ) 	// Light Damage
		ArmorDamage = Damage * ArmorAbsorption / 100;

	else if ( DamageType.static.IsOfType(DAMAGE_Medium) )	// Med. Damage
		ArmorDamage = Damage * (ArmorAbsorption*0.75) / 100;	
	else
		ArmorDamage = Damage;

	Charge = Clamp(Charge - ArmorDamage,0,100);
	return (ArmorDamage);
}


function ArmorEffect(int Damage, class<DamageType> DamageType, vector HitLocation)
{
	// Play some nice sparks
	spawn(class'WarBloodEffect',,,HitLocation,rotator(Location-HitLocation));	
	PlaySound(Impacts[rand(3)], SLOT_Misc, 1.0);	
}


defaultproperties
{
	Impacts[0]=Sound'BulletSounds.Dirt.BulletHit_dirt1'
	Impacts[1]=Sound'BulletSounds.Dirt.BulletHit_dirt2'
	Impacts[2]=Sound'BulletSounds.Dirt.BulletHit_dirt3'
	ArmorAbsorption=50
	AbsorptionPriority=1000
	Charge=50
}