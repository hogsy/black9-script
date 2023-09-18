// ====================================================================
//  Class:  WarClassLight.WarfareArmor
//
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================
class WarfareArmor extends Armor;

// Used to describe the type of damage.  

const DAMAGE_None      = 0;
const DAMAGE_Light     = 1;
const DAMAGE_Medium	   = 2;
const DAMAGE_Heavy     = 4;
const DAMAGE_Fatal     = 8;
const DAMAGE_Explosive = 16;
const DAMAGE_Energy	   = 32;
const DAMAGE_ArmorKiller = 64;

var() int		  ArmorAbsorption;	  // Percent of damage item absorbs 0-100.
var() int		  AbsorptionPriority; // Which items absorb damage first (higher=first).
var   armor		  NextArmor;		  // Temporary list created by Armors to prioritize damage absorption.

//
// Absorb damage.
//

function int ArmorAbsorbDamage(int Damage, class<DamageType> DamageType, vector HitLocation)
{
	local int ArmorDamage;

	if ( (!CanStop(DamageType) ) || (Charge == 0) )
		return Damage;

	ArmorEffect(Damage, DamageType, HitLocation);
		
	ArmorDamage = (Damage * ArmorAbsorption) / 100;
	if( ArmorDamage >= Charge )
	{
		ArmorDamage = Charge;
		Charge = 0;
	}
	else 
		Charge -= ArmorDamage;
		
	Charge = Max(0,Charge);
	return (Damage - ArmorDamage);
}

//
// Return armor value.
//
function int ArmorPriority(class<DamageType> DamageType)
{
	if ( !CanStop(DamageType) )
		return 0;
	else
		return AbsorptionPriority;
}

//
// This function is called by ArmorAbsorbDamage and displays a visual effect 
// for an impact on an armor.
//

function ArmorEffect(int Damage, class<DamageType> DamageType, vector HitLocation);

state Activated
{
	function BeginState()
	{
		Super.BeginState();
		if ( ProtectionType != None )
			Pawn(Owner).ReducedDamageType = ProtectionType;
	}

	function EndState()
	{
		Super.EndState();
		if ( (Pawn(Owner) != None) && (ProtectionType != Pawn(Owner).ReducedDamageType) )
			Pawn(Owner).ReducedDamageType = None;
	}
}

//
// Return the best armor to use.
//

function armor PrioritizeArmor( int Damage, class<DamageType> DamageType, vector HitLocation )
{
	local Armor FirstArmor, InsertAfter;

	if ( Inventory != None )
		FirstArmor = Inventory.PrioritizeArmor(Damage, DamageType, HitLocation);
	else
		FirstArmor = None;

	if ( FirstArmor == None )
	{
		nextArmor = None;
		return self;
	}

	// insert this armor into the prioritized armor list
	if ( FirstArmor.ArmorPriority(DamageType) < ArmorPriority(DamageType) )
	{
		nextArmor = FirstArmor;
		return self;
	}
	InsertAfter = FirstArmor;
	while ( (InsertAfter.nextArmor != None) 
		&& (InsertAfter.nextArmor.ArmorPriority(DamageType) > ArmorPriority(DamageType)) )
		InsertAfter = InsertAfter.nextArmor;

	nextArmor = InsertAfter.nextArmor;
	InsertAfter.nextArmor = self;

	return FirstArmor;
}

//
// CanStop - Looks at the Damage Type and determines if the armor can stop it
//

function bool CanStop(class<DamageType> DamageType)
{
	return true;
}

