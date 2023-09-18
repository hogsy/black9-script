// ====================================================
// StaticView
// ====================================================

class StaticView extends Interaction;

#exec TEXTURE IMPORT NAME=LockCHair  FILE=Textures\LockCHair.PCX GROUP="Icons"
#exec TEXTURE IMPORT NAME=LockCHair2  FILE=Textures\LockCHair2.PCX GROUP="Icons"

#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax PACKAGE=WeaponSounds

var float CrossHairX, CrossHairY, CenterX, CenterY;
var bool ResetCrossHair;
var WarfarePlayer Controller;
var vector AimTarget;
var pawn PointingAt;
 

function Activate()
{
	bActive = true;
	bVisible = true;
	AimTarget = vect(0,0,0);
	PointingAt = none;	
	ResetCrossHair = true;	
	
}

function DeActivate()
{
	bActive = false;
	bVisible = false;
	controller.Pawn.AmbientSound = none;
}

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	local byte k;
	local float OldCrossHair;
	k = Key;

	switch (Action)
	{
		case IST_Axis:
			switch (Key)
			{
				case IK_MouseX:
					OldCrossHair = CrossHairX;
					CrossHairX = CrossHairX + (1 * Delta);
					CalcAimSpot();
					return true;
					break;

				case IK_MouseY:
					CrossHairY = CrossHairY - (1 * Delta);
					CalcAimSpot();
					return true;
					break;					
			}
		default:
			break;
	}
	return false;
}

function PostRender( canvas Canvas )
{
	local float perc;

	// Reset the CrossHair if needed
	
	if (ResetCrossHair)
	{
		ResetCrossHair = false;
		CrossHairX = Canvas.ClipX /2;
		CrossHairY = Canvas.ClipY /2;
	}
	else // Bounds Check the Crosshair
	{
		if (CrossHairX<0)
			CrossHairX=0;
		else if (CrossHairX>Canvas.ClipX)
			CrossHairX=Canvas.ClipX;
			
		if (CrossHairY<0)
			CrossHairY=0;
		else if (CrossHairY>Canvas.ClipY)
			CrossHairY=Canvas.ClipY;
	}		

	CenterX = Canvas.ClipX / 2;
	CenterY = Canvas.ClipY / 2;
	
	CalcAimSpot();


	
	Canvas.bNoSmooth = False;
	Canvas.SetPos(CrossHairX-32, CrossHairY-32);
	Canvas.Style = 3;
	Canvas.SetDrawColor(255,255,255);
	
	if (PointingAt==None)
	{
		Canvas.DrawTile(texture 'LockCHair', 64,64,0,0,84,84); //84,84);
		controller.Pawn.AmbientSound = none;
	}
	else
	{
		Canvas.DrawTile(texture 'LockCHair2',64,64,0,0,84,84); //84,84);
		Controller.Pawn.AmbientSound = sound 'WeaponSounds.HeavyLock';
	}


	Canvas.bNoSmooth = True;
	Canvas.Style = 1;
	
    // Calc the view adjustment
	
	if ( int(CrossHairX) != int(Canvas.ClipX/2) )
	{	
		Perc = CrossHairX / Canvas.ClipX;
		Controller.ViewChange.Yaw = (4096 * Perc) - 2048;
	}
	else
	  Controller.Viewchange.Yaw = 0;
	
	if ( int(CrossHairY) != int(Canvas.ClipY/2) )
	{
		Perc = 1-(CrossHairY / Canvas.ClipY);
		Controller.ViewChange.Pitch = (4096 * Perc) - 2048;
	}
	else
		Controller.ViewChange.Pitch = 0;
	
}

function CalcAimSpot()
{
	local vector StartTrace, X,Y,Z, Project, Direction;
	local actor Other;

	if ( (Controller==None) || (Controller.Pawn==None) || (Controller.Pawn.Weapon==None) )
		return;

	GetAxes(Controller.Pawn.GetViewRotation(),X,Y,Z);
	StartTrace = Controller.Pawn.Weapon.GetFireStart(X,Y,Z);

	Project.X = CrossHairX;
	Project.Y = CrossHairY;

	Direction  = ScreenToWorld(Project);
	AimTarget = StartTrace + Controller.Pawn.Weapon.TraceDist * Normal(Direction);

	Other = Controller.Pawn.Trace(x,y,AimTarget,StartTrace,True);
	PointingAt = pawn(Other);
	
	if (Other!=None && ( (Other.IsInState('Dying') || Other.bHidden || Other.bDeleteMe)) )
		PointingAt = None;

}




defaultproperties
{
	bActive=false
}