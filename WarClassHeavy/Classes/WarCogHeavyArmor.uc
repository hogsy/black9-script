// ====================================================================
//  Class:  WarClassHeavy.WarCogHeavyArmor
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarCogHeavyArmor extends WarfareArmor;

#exec OBJ LOAD FILE=..\Sounds\BulletSounds.uax PACKAGE=BulletSounds

var sound Impacts[6];

function int ArmorAbsorbDamage(int Damage, class<DamageType> DamageType, vector HitLocation)
{
	local float ArmorDamage;

	if ( (!CanStop(DamageType) ) || (Charge <= 0) )	
		return Damage;

	if (DamageType.static.IsOfType(DAMAGE_ArmorKiller) )	// Handle Armor killers first
	{
		Charge = Clamp(Charge-15,0,Charge);
		return 1;
	}	

	ArmorEffect(Damage, DamageType, HitLocation);

	// Special Case for Explosive Ammo
	
	if (DamageType.static.IsOfType(DAMAGE_Explosive))
	{
		if (DamageType.static.IsOfType(DAMAGE_Heavy) )
		{
			Charge = Clamp(Charge-45,0,100);
		}
			
		return Damage; 
	}
	else if (DamageType.static.IsOfType(DAMAGE_Fatal))	// Special case for Headshots
	{
		return Damage;
	}
	else if (DamageType.static.IsOfType(DAMAGE_Light) || DamageType.static.IsOfType(DAMAGE_Medium) ) 	// Light/Medium Armor
	{
		ArmorDamage = float(Damage) - ( float(Damage) * ( float(Charge) / 100.0) );
		if (ArmorDamage<2.0)
			ArmorDamage=2.0;

		Charge = Clamp(Charge-(ArmorDamage*2),0,100);
	}
	else
	{
		ArmorDamage = Damage * 0.5;
		Charge = Clamp(Charge-45,0,100);
	}
		
	return (ArmorDamage);
}

function ArmorEffect(int Damage, class<DamageType> DamageType, vector HitLocation)
{
	// Play some nice sparks
	
	local int i;
	
	if (DamageType==class'WarDamageA9Explosive')
	{
		Instigator.PlaySound(Impacts[5],SLOT_Misc,1.0);	
	}
	else
	{
		i = rand(5);
		Instigator.PlaySound(Impacts[i],SLOT_Misc,1.0);
		spawn(class'PclCOGHeavyBulletSpark',,,HitLocation,rotator(Location-HitLocation));	
	}
}


defaultproperties
{
	Impacts[0]=Sound'BulletSounds.Metal.bullet_metal1'
	Impacts[1]=Sound'BulletSounds.Metal.bullet_metal2'
	Impacts[2]=Sound'BulletSounds.Metal.bullet_metal3'
	Impacts[3]=Sound'BulletSounds.Ricochet.BulletRic_Metal0'
	Impacts[4]=Sound'BulletSounds.Ricochet.BulletRic_Metal0'
	Impacts[5]=Sound'BulletSounds.Metal.BulletHit_Metal4'
	ArmorAbsorption=90
	AbsorptionPriority=1000
	Charge=100
}