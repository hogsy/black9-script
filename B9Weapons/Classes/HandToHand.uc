//=============================================================================
// HandToHand.uc
//
// default melee weapon (fists)
//
// 
//=============================================================================


class HandToHand extends B9MeleeWeapon;


//var HandToHand_collision		fLeftHand;
//var HandToHand_collision		fRightHand;

/////////////////////////////////////////////////
// Overrides from B9WeaponBase
//

// Much code was moved to B9MeleeWeapon.

state NormalFire
{
	function Fire(float F) {}
	function AltFire(float F) {} 

	/*
	function MeleeFire()
	{
		local B9_AdvancedPawn		P;
		local class <DamageType>	meleeDamageType;
		local int					meleeDamageAmount;


		P = B9_AdvancedPawn( Owner );
		if( P == None )
		{
			return;
		}


		// Determine the type of damage we'll be doing with this punch.
		// If a melee-specific skill is active then we'll use the skill's
		// damage type & amount. Otherwise we use the standard "punch in the face" damage type
		//
		if(		P.fSelectedSkill != None
			&&	P.fSelectedSkill.IsMeleeEnhancer()
			&&	P.fSelectedSkill.fActive
			)
		{
			meleeDamageType		= P.fSelectedSkill.fMyDamageType;
			meleeDamageAmount	= P.fSelectedSkill.GetDamage();
		}

		else
		{
			meleeDamageType		= class'damage_HandToHand';
			meleeDamageAmount	= 10;
		}

		// Now spawn a "melee projectile" for each hand and give it the correct damage type
		//
		if( fRightHand != None )
		{
			fRightHand.Destroy();
			fRightHand = None;
		}

		fRightHand	= Spawn( class'HandToHand_collision', P, , P.Location, P.Rotation );
		fRightHand.MyDamageType	= meleeDamageType;
		fRightHand.Damage		= meleeDamageAmount;
		P.AttachToBone( fRightHand, 'NanoBone' );


		if( fLeftHand != None )
		{
			fLeftHand.Destroy();
			fLeftHand = None;
		}

		fLeftHand	= Spawn( class'HandToHand_collision', P, , P.Location, P.Rotation );
		fLeftHand.MyDamageType	= meleeDamageType;
		fLeftHand.Damage		= meleeDamageAmount;
		P.AttachToBone( fLeftHand, 'weaponbone' );
		

		P.bMeleeAttack = true;

		if( fLeftHand == None )
		{
			log( "## Failed to spawn left hand" );
		}
		if( fRightHand == None )
		{
			log( "## Failed to spawn right hand" );
		}
	}
	*/

	function MeleeFire()
	{
		local B9_AdvancedPawn		P;
		local class <DamageType>	meleeDamageType;
		local int					meleeDamageAmount;
		local Pawn					targetPawn;
		local vector				targetDir, X, Y, Z;


		P = B9_AdvancedPawn( Owner );
		if( P == None )
			return;

		// Determine the type of damage we'll be doing with this punch.
		// If a melee-specific skill is active then we'll use the skill's
		// damage type & amount. Otherwise we use the standard "punch in the face" damage type
		//
		if(		P.fSelectedSkill != None
			&&	P.fSelectedSkill.IsMeleeEnhancer()
			&&	P.fSelectedSkill.fActive
			)
		{
			meleeDamageType		= P.fSelectedSkill.fMyDamageType;
			meleeDamageAmount	= P.fSelectedSkill.GetDamage();
		}

		else
		{
			meleeDamageType		= class'damage_HandToHand';
			meleeDamageAmount	= P.fMeleeAttackDamage;
		}

		P.bMeleeAttack = true;
		FindTargetAndDamage(meleeDamageAmount, P.fMeleeAttackMomentum, meleeDamageType);
	}

Begin:
	MeleeFire();
	Sleep( GetROF() );
	Finish();
}



//////////////////////////////////
// Variables
//







defaultproperties
{
	fDamageRadius=100
	fUsesAmmo=false
	fUsesClips=false
	fMeleeWeapon=true
	fMeleeDamage=10
	fIniLookupName="Fist"
	AmmoName=Class'HandToHand_Ammunition'
	ReloadCount=1
	TraceDist=100
	MaxRange=100
	PickupClass=Class'HandToHand_Pickup'
	AttachmentClass=Class'HandToHand_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.hand_to_hand_bricon'
	ItemName="Hand To Hand"
	DrawType=0
}