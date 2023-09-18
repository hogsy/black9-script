
class B9_Crosshair extends Interaction;


var Vector		screenPos;
var int			fTickCount;

function Initialized()
{
}


function PostRender( canvas Canvas )
{
	local PlayerController	pc;
	local Vector			HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local Actor				hitActor;
	local B9_Pawn			hitPawn;
	local B9_BasicPlayerPawn	PP;
	local B9WeaponBase		wep;
	local float				width;
	local float				acc;
	local bool				bSeekTargetThisFrame;


	fTickCount++;
	if( fTickCount % 3 == 0 )
	{
		bSeekTargetThisFrame = true;
		fTickCount = 0;
	}
	else
	{
		bSeekTargetThisFrame = false;
	}

	pc = ViewportOwner.Actor;
	if( pc == None || pc.Pawn == None || pc.Pawn.Weapon == None || B9WeaponBase( pc.Pawn.Weapon ).fUniqueID == wepID_RifleSniper )
	{
		return;
	}

	PP = B9_BasicPlayerPawn( pc.Pawn );
	if( PP == None )
	{
		return;
	}

	if (B9_HUD(pc.myHUD).fHideHUD)
		return;

	wep = B9WeaponBase( PC.Pawn.Weapon );
	if( wep == None )
	{
		return;
	}

	// B9_PlayerController establishes whether the target is still locked or not
	// If it is, just draw the crosshair at that location
	//
	if( PP.fGuidedTarget != None )
	{
		screenPos = WorldToScreen( PP.fGuidedTarget.GetTargetLocation() );
	}

	// If there is no target, search for a new one and lock to it
	//
	else if( bSeekTargetThisFrame )
	{
		GetAxes( pc.GetViewRotation(), X, Y, Z );
		StartTrace = pc.Pawn.Weapon.GetFireStart( X, Y, Z );
		EndTrace = StartTrace;
		X = vector( pc.GetViewRotation() );
		EndTrace += pc.Pawn.Weapon.TraceDist * X;

		hitActor = pc.Pawn.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true );

		if( hitActor == None || wep.fProjectileWeapon )
		{
			PP.SetGuidedTarget( None );
			screenPos = WorldToScreen( EndTrace );
		}
		else
		{
			hitPawn = B9_Pawn( hitActor );
			if( hitPawn == None || hitPawn.Health <= 0 || hitPawn.fNoTargetLock )
			{
				PP.SetGuidedTarget( None );
				screenPos = WorldToScreen( EndTrace );
			}
			else
			{
				PP.SetGuidedTarget( hitPawn );
				screenPos = WorldToScreen( hitPawn.GetTargetLocation() );
			}
		}
	}

	if (wep.fMaxInaccuracy > 0.0)
	{
		acc = wep.TraceAccuracy;
		if (acc < 0.0f) acc = 0.0f;
		if (acc > wep.fMaxInaccuracy) acc = wep.fMaxInaccuracy;

		width = (32.0f * acc) / wep.fMaxInaccuracy + 32.0f;
	}
	else
	{
		width = 32.0f;
	}

	Canvas.Style = wep.ERenderStyle.STY_Normal;
	Canvas.SetDrawColor( 255, 255, 255, 128 );

	Canvas.SetPos( screenPos.X - width / 2, screenPos.Y - 1 );
	Canvas.DrawRect(Texture'engine.WhiteSquareTexture', width / 4, 2);
	Canvas.SetPos( screenPos.X + width / 2 - width / 4, screenPos.Y - 1 );
	Canvas.DrawRect(Texture'engine.WhiteSquareTexture', width / 4, 2);
	Canvas.SetPos( screenPos.X - 1, screenPos.Y - width / 2 );
	Canvas.DrawRect(Texture'engine.WhiteSquareTexture', 2, width / 4);
	Canvas.SetPos( screenPos.X - 1, screenPos.Y + width / 2 - width / 4 );
	Canvas.DrawRect(Texture'engine.WhiteSquareTexture', 2, width / 4);
	Canvas.SetPos( screenPos.X - 1, screenPos.Y - 1 );
	Canvas.DrawRect(Texture'engine.WhiteSquareTexture', 2, 2);
}



defaultproperties
{
	bVisible=true
}