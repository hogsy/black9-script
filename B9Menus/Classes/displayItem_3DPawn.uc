class displayItem_3DPawn extends displayItem;

var class<Pawn> fPawnClass;
var B9_PDABase fPDA;
var string fCharName;
var Pawn fPawn;
var vector fLocation;
var float fScale;
var int fRotation;
var float fRotationRate;
var float fLastTimeSeconds;


function Setup( B9_PDABase pdaBase )
{
	local rotator newRotation;
	local vector loc;
	local Actor A;
	
	fPDA = pdaBase;
	//InsurePlayerIsSet( fPawnClass, fPDA );	
	//fPawn.SetCollision( false, false, false );
	
	ForEach fPDA.RootController.AllActors( class'Actor', A )
	{
		if ( A.Name == 'LookTarget0' )
		{
			loc = A.location;
			break;
		}
	}
	//fPawn = fPDA.RootController.spawn( fPawnClass, , , fLocation );
	fPawn = fPDA.RootController.spawn( fPawnClass, , , loc );
	
//	fPawn.SetLocation( fLocation );
	newRotation = fPawn.Rotation;
	newRotation.yaw += fRotation;
	fPawn.SetRotation( newRotation );
	fPawn.SetCollision( false, false, false );
	fPawn.SetDrawScale( fScale );

	B9_Pawn( fPawn ).AnimateStanding();

	fLastTimeSeconds	= fPawn.Level.Level.TimeSeconds;
}

function SetupPawn( class<Pawn> pawnClass, vector location, float scale, int yawRotation )
{
	fPawnClass = pawnClass;
	fLocation =	location;
	fScale = scale;
	fRotation =	yawRotation;
	fRotationRate	= 8192;
}

function bool handleKeyEvent( Interactions.EInputKey KeyIn, out Interactions.EInputAction Action, float Delta)
{
// Default handler handles nothing overload this to add functionality
	return false;
}

function ClickItem(optional B9_MenuPDA_Menu menu)
{
	Super.ClickItem( menu );
}

function bool Draw(canvas Canvas, int focus, out int beginPoint_X, out int beginPoint_Y,int endPoint_X, int endPoint_Y, out B9_PDABase PDA)
{
	local float		DeltaTime;
	local Rotator	newRotation;

	// Update Rotation
	DeltaTime			= fPawn.Level.TimeSeconds - fLastTimeSeconds;
	fLastTimeSeconds	= fPawn.Level.TimeSeconds;
	// Update Animation
	//@@PDS need to either blend properly, or know when the anim is done

	newRotation		= fPawn.Rotation;
	newRotation.Yaw	+= DeltaTime * fRotationRate;
	fPawn.SetRotation( newRotation );

	Canvas.DrawActor( fPawn, false, true );	
	
	return  Super.Draw(Canvas, focus, beginPoint_X, beginPoint_Y,endPoint_X, endPoint_Y, PDA);	
}

function InsurePlayerIsSet( class<Pawn> pawnType, B9_PDABase PDA )
{
	local Pawn oldPawn;
	local Actor A;
	local vector loc;
	local Inventory Inv;
	local class<Inventory> DefaultSkill;
	local class<Inventory> DefaultWeapon;
	local class<Inventory> DefaultItem;
	local B9WeaponBase		b9Weapon;
	local int i;

	Log( "MMenu: Attempting to spawn " $ pawntype );

	ForEach PDA.RootController.AllActors( class'Actor', A )
	{
		if ( A.Name == 'LookTarget0' )
		{
			loc = A.location;
			break;
		}
	}

	Log( "MMenu: Attempting to spawn " $ pawntype );
	fPawn = PDA.RootController.spawn( pawnType, , , loc );

	if ( fPawn != None )
	{
		Log( "MMenu: spawned" );

		/*if ( PDA.RootController.pawn != None )
		{
			Log( "MMenu: unpossess" );

			oldPawn = PDA.RootController.pawn;
			PDA.RootController.UnPossess();
			oldPawn.Destroy();
		}

		Log( "MMenu: possess" );

		PDA.RootController.Possess( fPawn );
		*/
	}
	else
		Log( "MMenu: Failed to create pawn" );
}
