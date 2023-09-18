//=============================================================================
// B9_TargetingReticule
//
// 
//
// 
//=============================================================================

class B9_TargetingReticule extends Actor;

var protected transient CanvasUtility fCanvasUtility;

var protected material fAimReticuleTex;
var protected material fTargetReticuleCornerTex;
var protected material fTargetInfoActionsBorderTex;
var protected material fTargetInfoActionsAttackTex;
var protected material fTargetInfoActionsHackTex;
var protected material fTargetInfoActionsTalkTex;
var protected material fTargetInfoActionsUseTex;
var protected material fTargetInfoActionsPickUpTex;
var protected material fTargetInfoStatusBorderTex;
var protected material fTargetInfoStatusHealthTex;
var protected material fTargetInfoStatusFocusTex;
var protected material fTargetInfoStatusVehicleTex;
var protected bool	   fTargetIsHackable;
const kAimTextureSize				= 64;
const kTargetBracketWidth			= 16;
const kTargetBracketHeight			= 16;
const kTargetInfoWidth				= 256;
const kTargetInfoHeight				= 128;
const kTargetInfoActionWidth		= 128;
const kTargetInfoActionHeight		= 128;
const kTargetInfoStatusWidth		= 117;
const kTargetInfoStatusHeight		= 16;
const kTargetInfoStatusLeft			= 131;
const kTargetInfoStatusHealthTop	= 17;
const kTargetInfoStatusFocusTop		= 47;
const kTargetInfoStatusVehicleTop	= 76;


// debug info
var bool	fShowTargetInfo;
var bool	fShowTargetingSkill;




function B9Debug( String mode, optional String data )
{
	if ( mode == "info" )
	{
		fShowTargetInfo	= !fShowTargetInfo;
	}
	else
	if ( mode == "skill" )
	{
		fShowTargetingSkill	= !fShowTargetingSkill;
	}
}

function PreBeginPlay()
{
	Super.PreBeginPlay();

	fCanvasUtility = new(none) class'CanvasUtility';
}

event PostLoadGame()
{
	Super.PostLoadGame();

	// Restore transient objects.
	fCanvasUtility = new(none) class'CanvasUtility';
}

function SetHackableBit()
{
	fTargetIsHackable = true;
}

function bool IsPawnHackable(Actor target)
{
	local B9_HUD			myHUD;
	local B9_AdvancedPawn	advancedPawn;


	fTargetIsHackable = false;

	myHUD	= B9_HUD( Owner );

	if ( myHUD != None )
	{
		advancedPawn	= myHUD.GetAdvancedPawn();
		if ( advancedPawn != None )
		{
			target.Trigger( self,  advancedPawn  );
		}
	}

	return fTargetIsHackable;
}

function B9_HUD.tTargetItem GetLockedTarget( B9_HUD myHUD )
{
	local B9_HUD.tTargetItem	targetItem;
	local int					itTarget;
	local B9_BasicPlayerPawn	P;
	local PlayerController		PC;


	myHUD	= B9_HUD( Owner );
	if( myHUD == None )
	{
		return targetItem;
	}

	PC = myHUD.PlayerOwner;
	if( PC == None )
	{
		return targetItem;
	}

	P = B9_BasicPlayerPawn( PC.Pawn );
	if( P == None )
	{
		return targetItem;
	}
	
	for ( itTarget = 0; itTarget < myHUD.fTargets.Length; ++itTarget )
	{
		if( myHUD.fTargets[ itTarget ].fActor == P.fGuidedTarget )
		{
			targetItem	= myHUD.fTargets[ itTarget ];
			break;
		}
	}

	return targetItem;
}

function DrawAimReticule( Canvas canvas, B9_HUD myHUD, B9_AdvancedPawn advancedPawn, B9_HUD.tTargetItem targetItem )
{
	local B9WeaponBase		playerWeapon;
	local vector	X, Y, Z;
	local vector	hitLocation, hitNormal, traceEnd, traceStart;
	local vector	screen;
	local float		scaledSize;
	local float		lockTTL;
	local float		lockTTLPct;
	local vector	timerVector;
	local rotator	timerRotator;


	// No aim reticle in Sniper Mode
	playerWeapon	= B9WeaponBase( advancedPawn.Weapon );
	if ( ( playerWeapon != None ) && playerWeapon.fHasScope && playerWeapon.fZoomed )
	{
		return;
	}

	if ( advancedPawn.Weapon != None )
	{
		GetAxes( advancedPawn.GetViewRotation(), X, Y, Z );
		traceStart	= advancedPawn.Weapon.GetFireStart( X, Y, Z );
		traceEnd	= traceStart + X * 10000;
		if ( Trace ( hitLocation, hitNormal, traceEnd, traceStart, false ) == None )
		{
			hitLocation = traceEnd;
		}

		screen		= fCanvasUtility.Project( canvas, hitLocation );
		scaledSize	= kAimTextureSize;

		if ( screen.z >= 0 )
		{
			canvas.Style		= ERenderStyle.STY_Translucent;
			canvas.SetDrawColor( 255, 255, 255 );

			canvas.SetPos( screen.x - scaledSize * 0.5, screen.y - scaledSize * 0.5 );
			canvas.DrawTile( fAimReticuleTex, scaledSize, scaledSize, 0, 0, kAimTextureSize - 1, kAimTextureSize - 1 );

			if ( targetItem.fLocked )
			{
				// this creates a screen vector that rotates around the target location
				// based on how much lock strength time is left
				lockTTL				= 1.0 + ( 2.0 * advancedPawn.GetTargetingSkill() / 100.0 );
				lockTTLPct			= ( Level.TimeSeconds - targetItem.fTimeLocked ) / lockTTL;
				timerRotator.yaw	= -Int( lockTTLPct * 65535.0 );
				timerVector			= ( ( vect( 0, -1, 0 ) * ( scaledSize / 2 ) ) >> timerRotator ) + screen;

				// target lock timer
				if ( timerRotator.yaw != 0 )
				{
					canvas.Style = ERenderStyle.STY_Translucent;
					canvas.SetDrawColor( 255 * ( lockTTLPct ), 255 * ( 1 - lockTTLPct ), 0 );

					Canvas.SetPos( timerVector.x - 1, timerVector.y - 1 );
					Canvas.DrawBox( Canvas, 2, 2 );
				}
			}
		}
	}
}

function DrawTargetInfo( Canvas canvas, B9_HUD myHUD, B9_AdvancedPawn advancedPawn, B9_HUD.tTargetItem targetItem )
{
		local float	scale;
		local float	targetInfoWidth;
		local float	targetInfoHeight;
		local float	targetInfoActionWidth;
		local float	targetInfoActionHeight;
		local float targetInfoStatusWidth;
		local float targetInfoStatusHeight;
		local float targetInfoStatusLeft;
		local float targetInfoStatusHealthTop;
		local float targetInfoStatusFocusTop;
		local float targetInfoStatusVehicleTop;
		local float	left;
		local float	top;
		local B9_AdvancedPawn	targetPawn;
		local int				HUDActions;
		local float				targetHealth;
		local float				targetHealthHit;
		local float				targetFocus;
		local float				targetFocusHit;
		local float				targetVehicle;
		local float				targetVehicleHit;
		local String			targetHealthText;
		local String			targetFocusText;
		local String			targetSkillText;
		local float				w, textHeight;


		if ( targetItem.fActor != None )
		{
			scale	= 0.5;
			targetInfoWidth				= kTargetInfoWidth * scale;
			targetInfoHeight			= kTargetInfoHeight * scale;
			targetInfoActionWidth		= kTargetInfoActionWidth * scale;
			targetInfoActionHeight		= kTargetInfoActionHeight * scale;
			targetInfoStatusWidth		= kTargetInfoStatusWidth * scale;
			targetInfoStatusHeight		= kTargetInfoStatusHeight * scale;
			targetInfoStatusLeft		= kTargetInfoStatusLeft * scale;
			targetInfoStatusHealthTop	= kTargetInfoStatusHealthTop * scale;
			targetInfoStatusFocusTop	= kTargetInfoStatusFocusTop * scale;
			targetInfoStatusVehicleTop	= kTargetInfoStatusVehicleTop * scale;

			left	= canvas.OrgX + 32;
			top		= canvas.ClipY - 32 - targetInfoHeight;

			HUDActions	= targetItem.fActor.GetHUDActions( advancedPawn );

			// actions icons
			canvas.Style = ERenderStyle.STY_Translucent;
			canvas.SetDrawColor( 255, 255, 255 );

			if ( ( HUDActions & kHUDAction_PickUp ) != 0 )
			{
				canvas.SetPos( left, top );
				canvas.DrawTile( fTargetInfoActionsPickUpTex, targetInfoActionWidth, targetInfoActionHeight, 0, 0, kTargetInfoActionWidth - 1, kTargetInfoActionHeight - 1 );
			}
			if ( ( HUDActions & kHUDAction_Use ) != 0 )
			{
				canvas.SetPos( left, top );
				canvas.DrawTile( fTargetInfoActionsUseTex, targetInfoActionWidth, targetInfoActionHeight, 0, 0, kTargetInfoActionWidth - 1, kTargetInfoActionHeight - 1 );
			}
			if ( ( HUDActions & kHUDAction_Hack ) != 0 )
			{
				canvas.SetPos( left, top );
				canvas.DrawTile( fTargetInfoActionsHackTex, targetInfoActionWidth, targetInfoActionHeight, 0, 0, kTargetInfoActionWidth - 1, kTargetInfoActionHeight - 1 );
			}
			if ( ( HUDActions & kHUDAction_Talk ) != 0 )
			{
				canvas.SetPos( left, top );
				canvas.DrawTile( fTargetInfoActionsTalkTex, targetInfoActionWidth, targetInfoActionHeight, 0, 0, kTargetInfoActionWidth - 1, kTargetInfoActionHeight - 1 );
			}
			if ( ( HUDActions & kHUDAction_Attack ) != 0 )
			{
				canvas.SetPos( left, top );
				canvas.DrawTile( fTargetInfoActionsAttackTex, targetInfoActionWidth, targetInfoActionHeight, 0, 0, kTargetInfoActionWidth - 1, kTargetInfoActionHeight - 1 );
			}

			// actions frame
			canvas.Style = ERenderStyle.STY_Translucent;
			canvas.SetDrawColor( 255, 255, 255 );

			canvas.SetPos( left, top );
			canvas.DrawTile( fTargetInfoActionsBorderTex, targetInfoActionWidth, targetInfoActionHeight, 0, 0, kTargetInfoActionWidth - 1, kTargetInfoActionHeight - 1 );

			targetPawn	= B9_AdvancedPawn( targetItem.fActor );
			if ( targetPawn != None )
			{
				targetHealth	= ( Float( targetPawn.Health ) / Float( targetPawn.fCharacterMaxHealth ) ) * targetInfoStatusWidth;
				//targetHealthHit	= targetInfoStatusWidth - targetHealth;

				targetFocus		= ( targetPawn.fCharacterFocus / targetPawn.fCharacterMaxFocus ) * targetInfoStatusWidth;
				//targetFocusHit	= targetInfoStatusWidth - targetFocus;

				//targetVehicle		= ( targetPawn. / targetPawn. ) * targetInfoStatusWidth;
				//targetVehicleHit	= targetInfoStatusWidth - targetFocus;

				canvas.Style = ERenderStyle.STY_Translucent;
				canvas.SetDrawColor( 255, 255, 255 );

				canvas.SetPos( left + targetInfoStatusLeft, top + targetInfoStatusHealthTop );
				canvas.DrawTile( fTargetInfoStatusHealthTex, targetHealth, targetInfoStatusHeight, 0, 0, targetInfoStatusWidth - 1, targetInfoStatusHeight - 1 );

				canvas.SetPos( left + targetInfoStatusLeft, top + targetInfoStatusFocusTop );
				canvas.DrawTile( fTargetInfoStatusFocusTex, targetFocus, targetInfoStatusHeight, 0, 0, targetInfoStatusWidth - 1, targetInfoStatusHeight - 1 );

				//canvas.SetPos( left + targetInfoStatusLeft, top + targetInfoStatusVehicleTop );
				//canvas.DrawTile( fTargetInfoStatusVehicleTex, targetVehicle, targetInfoStatusHeight, 0, 0, targetInfoStatusWidth - 1, targetInfoStatusHeight - 1 );

				if ( fShowTargetInfo )
				{
					canvas.TextSize( "I", w, textHeight );

					targetHealthText	= "Health: " $ targetPawn.Health $ "/" $ targetPawn.fCharacterMaxHealth;
					targetFocusText		= "Chi: " $ targetPawn.fCharacterFocus $ "/" $ targetPawn.fCharacterMaxFocus;

					canvas.Style = ERenderStyle.STY_Translucent;
					canvas.SetDrawColor( 255, 255, 255 );

					canvas.SetPos( left, top - textHeight );
					canvas.DrawTextClipped( String( targetPawn.Class.Name ) );
					canvas.SetPos( left + targetInfoWidth + 4, top );
					canvas.DrawTextClipped( targetHealthText );
					canvas.SetPos( left + targetInfoWidth + 4, canvas.CurY + textHeight );
					canvas.DrawTextClipped( targetFocusText );
				}
			}

			// status frame
			canvas.Style = ERenderStyle.STY_Translucent;
			canvas.Style = ERenderStyle.STY_Translucent;

			canvas.SetPos( left, top );
			canvas.DrawTile( fTargetInfoStatusBorderTex, targetInfoWidth, targetInfoHeight, 0, 0, kTargetInfoWidth - 1, kTargetInfoHeight - 1 );
		}
}

function DrawTargetReticule( Canvas canvas, B9_HUD myHUD, B9_HUD.tTargetItem targetItem )
{
	local vector				screen;
	local vector				X, Y, Z;
	local float					scale;
	local float					targetBracketWidth;
	local float					targetBracketHeight;
	local vector				bracketLT;
	local vector				bracketRT;
	local vector				bracketRB;
	local vector				bracketLB;
	local float					bracketHorzInset;
	local float					bracketVertInset;
	local float					scaledSize;
	local PlayerController		playerOwner;
	local String				playerSkillText;
	local float					w, textHeight;
	local Actor					viewActor;
	local Vector				cameraLocation;
	local Rotator				cameraRotation;


	//if ( ( targetItem.fActor != None ) && targetItem.fLocked )
	if( targetItem.fActor != None )
	{

		scale	= 1.0;
		targetBracketWidth	= kTargetBracketWidth * scale;
		targetBracketHeight	= kTargetBracketHeight * scale;

		playerOwner = myHUD.PlayerOwner;
		if ( playerOwner == None  )
		{
			return;
		}

		screen		= fCanvasUtility.Project( canvas, targetItem.fActor.Location );

		if ( screen.z >= 0 )
		{
//			if ( targetItem.fLocked )
//			{
				// orthogonal to the camera view
				playerOwner.PlayerCalcView( viewActor, cameraLocation, cameraRotation );//PDS@ is this stored already?
				GetAxes( cameraRotation, X, Y, Z );

				bracketLT	= fCanvasUtility.Project( Canvas, targetItem.fActor.Location + Z * targetItem.fActor.CollisionHeight + Y * -targetItem.fActor.CollisionRadius );
				bracketRT	= fCanvasUtility.Project( Canvas, targetItem.fActor.Location + Z * targetItem.fActor.CollisionHeight + Y * targetItem.fActor.CollisionRadius );
				bracketRB	= fCanvasUtility.Project( Canvas, targetItem.fActor.Location + Z * -targetItem.fActor.CollisionHeight + Y * targetItem.fActor.CollisionRadius );
				bracketLB	= fCanvasUtility.Project( Canvas, targetItem.fActor.Location + Z * -targetItem.fActor.CollisionHeight + Y * -targetItem.fActor.CollisionRadius );

				// this prevents the brackets from overlapping
				bracketHorzInset	= -FMin( 0, ( Abs( bracketRT.x - bracketLT.x ) / 2 ) - targetBracketWidth );
				bracketVertInset	= -FMin( 0, ( Abs( bracketRT.y - bracketRB.y ) / 2 ) - targetBracketHeight );

				canvas.Style = ERenderStyle.STY_Translucent;
				canvas.SetDrawColor( 255, 255, 255 );

				Canvas.SetPos( bracketLT.x - bracketHorzInset, bracketLT.y - bracketVertInset );
				Canvas.DrawTile( fTargetReticuleCornerTex, targetBracketWidth, targetBracketHeight, 0, 0, kTargetBracketWidth - 1, kTargetBracketHeight - 1 );

				Canvas.SetPos( bracketRT.x + bracketHorzInset, bracketRT.y - bracketVertInset );
				Canvas.DrawTile( fTargetReticuleCornerTex, -targetBracketWidth, targetBracketHeight, 0, 0, kTargetBracketWidth - 1, kTargetBracketHeight - 1 );

				Canvas.SetPos( bracketRB.x + bracketHorzInset, bracketRB.y + bracketVertInset );
				Canvas.DrawTile( fTargetReticuleCornerTex, -targetBracketWidth, -targetBracketHeight, 0, 0, kTargetBracketWidth - 1, kTargetBracketHeight - 1 );

				Canvas.SetPos( bracketLB.x - bracketHorzInset, bracketLB.y + bracketVertInset );
				Canvas.DrawTile( fTargetReticuleCornerTex, targetBracketWidth, -targetBracketHeight, 0, 0, kTargetBracketWidth - 1, kTargetBracketHeight - 1 );

				if ( fShowTargetingSkill )
				{
					canvas.TextSize( "I", w, textHeight );

					// focus as text
					playerSkillText	= "Targeting Skill: " $ myHUD.GetAdvancedPawn().GetTargetingSkill();

					canvas.Style = ERenderStyle.STY_Translucent;
					canvas.SetDrawColor( 255, 255, 255 );

					canvas.SetPos( bracketLT.x, bracketLT.y - textHeight );
					canvas.DrawTextClipped( playerSkillText );
				}
//			}
		}
	}
}

function Draw( Canvas canvas )
{
	local B9_HUD				myHUD; 
	local B9_AdvancedPawn		advancedPawn;
	local B9_HUD.tTargetItem	targetItem;
	

	// make sure we have a player
	myHUD	= B9_HUD( Owner );
	/*
	if ( myHUD != None )
	{
		advancedPawn	= myHUD.GetAdvancedPawn();
	}
	if ( advancedPawn == None )
	{
		return;
	}
	*/
	
	if( myHUD != None )
	{
		targetItem	= GetLockedTarget( myHUD );
		DrawTargetReticule( canvas, myHUD, targetItem );
	}
	
//	DrawAimReticule( canvas, targetItem );
	
//	DrawTargetInfo( canvas, myHUD, advancedPawn, targetItem );
}

defaultproperties
{
	fAimReticuleTex=Texture'B9HUD_textures.Targeting_reticles.aim_reticle'
	fTargetReticuleCornerTex=Texture'B9HUD_textures.Targeting_reticles.bracket_corner'
	fTargetInfoActionsBorderTex=Texture'B9HUD_textures.HUDActions.action_frame01_tex'
	fTargetInfoActionsAttackTex=Texture'B9HUD_textures.HUDActions.action_A_big_tex'
	fTargetInfoActionsHackTex=Texture'B9HUD_textures.HUDActions.action_H_big_tex'
	fTargetInfoActionsTalkTex=Texture'B9HUD_textures.HUDActions.action_T_big_tex'
	fTargetInfoActionsUseTex=Texture'B9HUD_textures.HUDActions.action_U_big_tex'
	fTargetInfoActionsPickUpTex=Texture'B9HUD_textures.HUDActions.action_U_big_tex'
	fTargetInfoStatusBorderTex=Texture'B9HUD_textures.HUDActions.action_frame02_tex'
	fTargetInfoStatusHealthTex=Texture'B9HUD_textures.HUDActions.action_health_tex'
	fTargetInfoStatusFocusTex=Texture'B9HUD_textures.HUDActions.action_chi_tex'
	fTargetInfoStatusVehicleTex=Texture'B9HUD_textures.HUDActions.action_vehicle_tex'
	bHidden=true
}