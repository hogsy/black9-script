/////////////////////////////////////////////////////////////
// B9_ActionMeter
//
//	Basically a progress bar that indicates the status of an
//	interaction between the player and some object. Disarming
//	a bomb, for example.
//


class B9_ActionMeter extends Interaction;


var private bool fIsInteracting;

function Initialized()
{
	log(self@"I'm alive");
}

function Think( float DeltaTime )
{
	Log( "B9_ActionMeter: thinking! Time: " $DeltaTime );
}


function PostRender( canvas Canvas )
{
	Super.PostRender( Canvas );

	if( fIsInteracting )
	{
		DrawActionMeter(Canvas);
	}
}

function DrawActionMeter( canvas Canvas )
{
	return;

	local float x, y;

	x = Canvas.ClipX / 2;
	y = 100; //Canvas.ClipY / 2;

	Canvas.SetPos( x, y );
	Canvas.DrawTile( texture'HealthTitle', 60, 60, 0, 0, 99, 16 );
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	if( Action == IST_Press && Key == IK_Enter )
	{
		fIsInteracting = true;	
	}
	else if( Action == IST_Release && Key == IK_Enter )
	{
		fIsInteracting = false;	
	}

	return false;
}



defaultproperties
{
	bVisible=true
	bRequiresTick=true
}