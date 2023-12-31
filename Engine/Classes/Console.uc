//=============================================================================
// Console - A quick little command line console that accepts most commands.

//=============================================================================
class Console extends Interaction;

#exec new TrueTypeFontFactory PACKAGE="Engine" Name=ConsoleFont FontName="Verdana" Height=12 AntiAlias=1 CharactersPerPage=256
#exec TEXTURE IMPORT NAME=ConsoleBK FILE=..\UWindow\TEXTURES\Black.PCX
#exec TEXTURE IMPORT NAME=ConsoleBdr FILE=..\UWindow\TEXTURES\White.PCX

// Constants.
const MaxHistory=16;		// # of command histroy to remember.

// Variables

var globalconfig byte ConsoleKey;			// Key used to bring up the console

var int HistoryTop, HistoryBot, HistoryCur;
var string TypedStr, History[MaxHistory]; 	// Holds the current command, and the history
var bool bTyping;							// Turn when someone is typing on the console
var bool bIgnoreKeys;						// Ignore Key presses until a new KeyDown is received

//////////////////////////////////////////////
// Demo mode
// SB/Taldren/4/9/03
//
var() transient bool		bRunningDemo;
var() transient float		TimeIdle;			// Time since last input.
var() globalconfig int		DemoMode;			// 0=none, 1=E3, 2=ship
var() globalconfig float	TimeBetweenDemo;	// Time spent at title screen.
var() globalconfig float	TimePerDemo;		// Time spent running in attract mode.
var() globalconfig String	DemoLevels[16];		// Map list for demos

var transient bool			bDelayForDisconnect;

//
// End changes
/////////////////////////////////

event NativeConsoleOpen()
{
}

//////////////////////////////////////////////
// Demo mode
// SB/Taldren/4/9/03
//
simulated function bool IsRunningDemo()
{
	return( bRunningDemo );
}

exec function EnterDemoDelay()
{
	if( DemoMode == 0 )
	{
		return;
	}

	TimeIdle = 0;
	bDelayForDisconnect = true;

	ConsoleCommand( "disconnect" );
}

exec function StartRollingDemo()
{
	local int i, tryCount;
	local String cmdString;

	if( DemoMode == 0 )
	{
		return;
	}

	TimeIdle			= 0;
	tryCount			= 1024;
	
	cmdString = "ClientTravel ";

	do
	{
		i = int ( FRand() * float (ArrayCount(DemoLevels)) );

		tryCount--;

		if (tryCount < 0)
		{
			log ("Couldn't find a random level to StartRollingDemo", 'Error');
			return;
		}

	} until (DemoLevels[i] != "")

	cmdString = cmdString $ DemoLevels[i];
	cmdString = cmdString $ "?SpectatorOnly=True?NumBots=10";

	
	bRunningDemo		= true;
	bDelayForDisconnect = false;

	ConsoleCommand( cmdString );
}

exec function StopRollingDemo( bool TimedOut )
{
	local String	cmdString;

	if( DemoMode == 0 )
	{
		return;
	}

	TimeIdle			= 0;
	bRunningDemo		= false;
	bDelayForDisconnect = false;
	
	cmdString = "ClientTravel B9Menu_Main?SpectatorOnly=";

	ConsoleCommand( cmdString );
}

simulated event Tick( float Delta )
{
	if( DemoMode == 0 )
	{
		return;
	}

	if( !IsInState('Typing') )
	{
        TimeIdle += Delta;
	}

	if( IsRunningDemo() )
	{
		if( ( !bDelayForDisconnect ) && ( TimePerDemo > 0.0 ) && ( TimeIdle > TimePerDemo ) )
		{
			EnterDemoDelay();
		}
		else if( bDelayForDisconnect && TimeIdle > 3.0 )
		{
			StopRollingDemo( true );
		}
	}
	else if( ( !bDelayForDisconnect ) && ( TimeBetweenDemo > 0.0 ) && ( TimeIdle > TimeBetweenDemo ) )
	{
		EnterDemoDelay();
	}

	else if( bDelayForDisconnect && TimeIdle > 3.0 )
	{
		StartRollingDemo();
	}
	
	
}
//
// End changes
/////////////////////////////////

//-----------------------------------------------------------------------------
// Exec functions accessible from the console and key bindings.

// Begin typing a command on the console.
exec function Type()
{
	TypedStr="";
	GotoState( 'Typing' );
}

exec function Talk()
{
	TypedStr="Say ";
	GotoState( 'Typing' );
}

exec function TeamTalk()
{
	TypedStr="TeamSay ";
	GotoState( 'Typing' );
}

event NotifyLevelChange()
{
}

//-----------------------------------------------------------------------------
// Message - By default, the console ignores all output.
//-----------------------------------------------------------------------------

event Message( coerce string Msg, float MsgLife);

//-----------------------------------------------------------------------------
// Check for the console key.

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	/////////////////////////////////////
	// Modified:  Sean C. Dumas/Taldren
	//
	if( Action!=IST_Press )
		return false;
	else if( Key==ConsoleKey )
	{
		TimeIdle = 0;
		GotoState('Typing');
		return true;
	}
	else 
	{
		if( DemoMode != 0 )
		{
			if( IsRunningDemo() )
			{
				EnterDemoDelay();
			}
			else
			{
				TimeIdle = 0;
			}
		}
		return false;

	}
	// End Modified
	/////////////////////////////////////
}

//-----------------------------------------------------------------------------
// State used while typing a command on the console.

state Typing
{
	exec function Type()
	{
		TypedStr="";
		gotoState( '' );
	}
	function bool KeyType( EInputKey Key, optional string Unicode )
	{
		if (bIgnoreKeys)
			return true;

		if( Key>=0x20 && Key<0x100 && Key!=Asc("~") && Key!=Asc("`") )
		{
			if( Unicode != "" )
				TypedStr = TypedStr $ Unicode;
			else
				TypedStr = TypedStr $ Chr(Key);
			return true;
		}
	}
	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local string Temp;

		if (Action== IST_PRess)
		{
			bIgnoreKeys=false;
		}

		if( Key==IK_Escape )
		{
			if( TypedStr!="" )
			{
				TypedStr="";
				HistoryCur = HistoryTop;
				return true;
			}
			else
			{
				GotoState( '' );
			}
		}
		else if( global.KeyEvent( Key, Action, Delta ) )
		{
			return true;
		}
		else if( Action != IST_Press )
		{
			return false;
		}
		else if( Key==IK_Enter )
		{
			if( TypedStr!="" )
			{
				// Print to console.
				Message( TypedStr, 6.0 );

				History[HistoryTop] = TypedStr;
				HistoryTop = (HistoryTop+1) % MaxHistory;

				if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
					HistoryBot = (HistoryBot+1) % MaxHistory;

				HistoryCur = HistoryTop;

				// Make a local copy of the string.
				Temp=TypedStr;
				TypedStr="";

				if( !ConsoleCommand( Temp ) )
					Message( Localize("Errors","Exec","Core"), 6.0 );

				Message( "", 6.0 );
				GotoState('');
			}
			else
				GotoState('');

			return true;
		}
		else if( Key==IK_Up )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryBot)
					HistoryCur = HistoryTop;
				else
				{
					HistoryCur--;
					if (HistoryCur<0)
						HistoryCur = MaxHistory-1;
				}

				TypedStr = History[HistoryCur];
			}
			return True;
		}
		else if( Key==IK_Down )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryTop)
					HistoryCur = HistoryBot;
				else
					HistoryCur = (HistoryCur+1) % MaxHistory;

				TypedStr = History[HistoryCur];
			}

		}
		else if( Key==IK_Backspace || Key==IK_Left )
		{
			if( Len(TypedStr)>0 )
				TypedStr = Left(TypedStr,Len(TypedStr)-1);
			return true;
		}
		return true;
	}

	function PostRender(Canvas Canvas)
	{
		local float xl,yl;
		local string OutStr;

		// Blank out a space

		Canvas.Style = 1;

		Canvas.Font	 = font'ConsoleFont';
		OutStr = "(>"@TypedStr$"_";
		Canvas.Strlen(OutStr,xl,yl);

		Canvas.SetPos(0,Canvas.ClipY-6-yl);
		Canvas.DrawTile( texture 'ConsoleBk', Canvas.ClipX, yl+6,0,0,32,32);

		Canvas.SetPos(0,Canvas.ClipY-8-yl);
		Canvas.SetDrawColor(0,255,0);
		Canvas.DrawTile( texture 'ConsoleBdr', Canvas.ClipX, 2,0,0,32,32);

		Canvas.SetPos(0,Canvas.ClipY-3-yl);
		Canvas.bCenter = False;
		Canvas.DrawText( OutStr, false );
	}

	function BeginState()
	{
		bTyping = true;
		bVisible= true;
		bIgnoreKeys = true;
		HistoryCur = HistoryTop;
	}
	function EndState()
	{
		bTyping = false;
		bVisible = false;
	}
}

defaultproperties
{
	ConsoleKey=9
	HistoryBot=-1
	TimeBetweenDemo=60
	TimePerDemo=120
	DemoLevels[0]="Demo_M09A01"
	DemoLevels[1]="Demo_M09A02"
	DemoLevels[2]="Demo_M09A03"
	bRequiresTick=true
}