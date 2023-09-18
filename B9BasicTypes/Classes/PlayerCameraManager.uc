//=============================================================================
// PlayerCameraManager
// 
// Class which handles the camera code for the PlayerController.  It uses
// PlayerController::GetCurrentPlayer() as it's focus. All calculations
// are done natively for speed.  
//
//=============================================================================
class PlayerCameraManager extends Object 
	native;


var Vector			CameraLocation;
var Rotator			CameraRotation;
var bool			bUseRootAsBase;

var	Vector			FollowCamOffsetDistance;
var Vector			NormalOffsetDistance;
var Vector			VariableOffsetDistance; // - Offset for items or weapons, etc.. - //

// Offset from the player's origin that the camera points towards
var	Vector			RotationTargetOffset;
var	Vector			GoalRotationTargetOffset;
var Vector			CachedLocation;
var Vector			NormalRotationTargetOffset;
var Vector			VariableRotationTargetOffset; // - Offset for items or weapons, etc.. - //

// Speed for things....
var float			RotationLerpRate;
var float			FollowCamSpeed;
var float			TargetOffsetInterpolationSpeed;
var float			LeftRightTurnModifier;
var float			MinCamDist; // - Minimum distance to try to stay away from the viewtarget - //
var bool			bPitchAdjustZoom; // - Adjust camera distance by rotation pitch - //

var PlayerController	Owner;
var float			DeltaTime;

function Init( PlayerController NewOwner )
{
	Owner = NewOwner;
//	SaveConfig();

	FollowCamOffsetDistance  = NormalOffsetDistance;
	RotationTargetOffset     = NormalRotationTargetOffset;
	GoalRotationTargetOffset = NormalRotationTargetOffset;
}

native(2024) final function CameraTick( float DeltaTime );

/*
This allows for adjusting the camera rotation and/or distance offsets,
this is useful for if you want to use a differant camera offset for ranged weapons, etc..
*/
function AdjustCamera(optional bool bReset)
{
	if (!bReset)
	{
		FollowCamOffsetDistance  = VariableOffsetDistance;
		GoalRotationTargetOffset = VariableRotationTargetOffset;
	}  
	else
	{
		FollowCamOffsetDistance  = NormalOffsetDistance;
		GoalRotationTargetOffset = NormalRotationTargetOffset;
	}
}

/*
This allows for dynamicly adjusting variable offsets
*/
function AdjustVariableOffset(vector NewDistance,vector NewRotation,optional bool bSaveChanges)
{
	VariableOffsetDistance       = NewDistance;
	VariableRotationTargetOffset = NewRotation;

//	if (bSaveChanges)
//		SaveConfig();
}


/*
	FollowCamOffsetDistance=(X=175.000000,Z=-100.000000)
	NormalOffsetDistance=(X=160.000000,Z=-90.000000)
	VariableOffsetDistance=(X=120.000000,Z=-80.000000)
	NormalRotationTargetOffset=(X=0.0,Y=0.0,Z=0.0)
	VariableRotationTargetOffset=(X=0.0,Y=0.0,Z=0.0)
	RotationTargetOffset=(Z=50.000000)
	RotationLerpRate=2.000000
	FollowCamSpeed=6.000000
	TargetOffsetInterpolationSpeed=1.000000
	LeftRightTurnModifier=1.000000
	MinCamDist=70.000000
	bPitchAdjustZoom=true
*/

/*
	FollowCamOffsetDistance=(X=175.000000,Z=-100.000000)
	
	NormalOffsetDistance=(X=200.000000,Z=-90.000000)
	NormalRotationTargetOffset=(X=0.0,Y=0.0,Z=90.0)
	
	VariableOffsetDistance=(X=120.000000,Z=-80.000000)
	VariableRotationTargetOffset=(X=0.0,Y=0.0,Z=0.0)
	
	RotationTargetOffset=(Z=50.000000)
	RotationLerpRate=2.000000
	FollowCamSpeed=8.000000
	TargetOffsetInterpolationSpeed=100.000000
	LeftRightTurnModifier=1.000000
	MinCamDist=70.000000
	bPitchAdjustZoom=true
*/


defaultproperties
{
	FollowCamOffsetDistance=(X=175,Y=0,Z=-100)
	NormalOffsetDistance=(X=160,Y=0,Z=-90)
	VariableOffsetDistance=(X=120,Y=0,Z=-80)
	RotationTargetOffset=(X=0,Y=0,Z=50)
	RotationLerpRate=2
	FollowCamSpeed=16
	TargetOffsetInterpolationSpeed=1
	LeftRightTurnModifier=1
	MinCamDist=70
	bPitchAdjustZoom=true
}