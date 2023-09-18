// ====================================================================
//  Class:  WarClassLight.GeistLightInfantry
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class GeistLightInfantry extends TestMoCapPawn;

var(AnimTweaks) float JumpPlayRate;

#exec OBJ LOAD FILE=..\animations\GeistStandardSoldiers.ukx PACKAGE=GeistStandardSoldiers

simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
	PlayAnim('death_headshot',1.0,0.15);
}

simulated event PlayJump()
{
	PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );

	BaseEyeHeight =  0.7 * Default.BaseEyeHeight;
	AnimBlendToAlpha(FALLINGCHANNEL,1,JumpBlendInTime);
	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
		PlayAnim('Jump_Peek_Tst',JumpPlayRate,,FALLINGCHANNEL);
	else
		PlayAnim('Jump_Stand_Up',JumpPlayRate,,FALLINGCHANNEL); 
	CurrentDir = DCLICK_None;
}

simulated event PlayLandingAnimation(float ImpactVel)
{
	local name animseq;
	local float animrate,animframe;

	if ( (impactVel > 0.06) || IsAnimating(FALLINGCHANNEL) ) 
	{
		GetAnimParams(FALLINGCHANNEL,AnimSeq,AnimRate,AnimFrame);
		if ( (AnimSeq == 'Jump_Peek_Tst') || (AnimSeq == 'Jump_Land_Tst') )
		{
			PlayAnim('Jump_Land_tst',1,LandingTweenInTime,FALLINGCHANNEL);
			return;
		}
		else if ( (AnimSeq == 'Jump_Stand_Up') || (AnimSeq == 'Jump_Stand_Down') )
		{
			PlayAnim('Jump_stand_down',1,LandingTweenInTime,FALLINGCHANNEL);
			return;
		}
	}
}

simulated event PlayFalling()
{
	local name animseq;
	local float animrate,animframe;

	GetAnimParams(FALLINGCHANNEL,AnimSeq,AnimRate,AnimFrame);

	if ( (AnimSeq == 'Jump_Peek_Tst') || (AnimSeq == 'Jump_Land_Tst') )
	{
		TweenAnim('Jump_Land_tst',0.7,FALLINGCHANNEL);
		MovementBlendStartTime = LandingBlendOutStart;
	}
	else if ( (AnimSeq == 'Jump_Stand_Up') || (AnimSeq == 'Jump_Stand_Down') )
		TweenAnim('Jump_stand_down',0.7,FALLINGCHANNEL);

	GetAnimParams(FALLINGCHANNEL,AnimSeq,AnimRate,AnimFrame);
}

defaultproperties
{
	JumpPlayRate=1
	Helmet=StaticMesh'character_helmetmeshes.Geist_helmets.GeistGruntHelmet1'
}