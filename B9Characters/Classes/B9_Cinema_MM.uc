//===============================================================================
//  [B9_Cinema_MM] 
//  clone of player_mutant_male just for cinematics. - DP
//===============================================================================

class B9_Cinema_MM extends B9_PlayerPawn;

//var AssassinShadow		Shadow;		//for simple oval shadow
//var vector			ShadowOffset;	//for simple oval shadow
//var ShadowProjector		Shadow;		//for detailed shadow

function name GetWeaponBoneFor(Inventory I)
{
	return 'weaponbone';
}


function WeaponHit()
{
	//	log( "WeaponHit!!!!!" );
	//	bMeleeAttack=false;
	//	ChangeAnimation();
}



function Touch( Actor Other )
{
	PlayerController(Controller).Touch( Other );
}

function UnTouch( Actor Other )
{
	PlayerController(Controller).UnTouch( Other );
}

auto state BaseState
{
	function BeginState()
	{
		SetTimer(0.1, false);
	}

	function EndState()
	{
		SetTimer(0.0, false);
	}
}

// !!!! TEST CODE: immunity to unclassified damage
function bool ImmuneToDamage( Pawn instigatedBy, Vector hitlocation, class<DamageType> damageType )
{
	/* AFSNOTE: Taken out to do play testing - replace with actual immunites to reinstate.
	Log("Player hit by " $ damageType.Name);
	return (damageType == class'DamageType');
	*/

	return false;
}
// END TEST CODE


  
defaultproperties
{
	fCharacterName="Gruber"
	fCharacterBaseStrength=50
	fCharacterBaseAgility=20
	fCharacterBaseDexterity=20
	fCharacterBaseConstitution=50
	AirSpeed=1000
	JumpZ=540
	WalkingPct=0.25
	CrouchedPct=0.25
	bPhysicsAnimUpdate=true
	MovementAnims[0]=nowpn_Run_F
	MovementAnims[1]=nowpn_Run_B
	MovementAnims[2]=nowpn_Run_Step_L
	MovementAnims[3]=nowpn_Run_Step_R
	Mesh=SkeletalMesh'B9_Cinema_Chars.B9_cinema_mm_mesh'
}