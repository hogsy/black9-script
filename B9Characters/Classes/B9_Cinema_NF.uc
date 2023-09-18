//===============================================================================
//  [B9_Cinema_NF] 
//  clone of player_normal_female just for cinematics. - DP
//===============================================================================

class B9_Cinema_NF extends B9_PlayerPawn;

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
	fCharacterName="Sahara"
	fCharacterBaseAgility=40
	fCharacterBaseDexterity=35
	fCharacterBaseConstitution=45
	fIsLeftHanded=true
	AirSpeed=1000
	JumpZ=540
	WalkingPct=0.25
	CrouchedPct=0.25
	bPhysicsAnimUpdate=true
	MovementAnims[0]=nowpn_Run_F
	MovementAnims[1]=nowpn_Run_B
	MovementAnims[2]=nowpn_Run_Step_L
	MovementAnims[3]=nowpn_Run_Step_R
	Mesh=SkeletalMesh'B9_Cinema_Chars.B9_Cinema_NF_mesh'
}