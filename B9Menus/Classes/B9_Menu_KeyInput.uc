class B9_Menu_KeyInput extends B9_MenuInteraction;

var material						fCursorKey;
var material						fUpDownKey;
var material						fLeftRightKey;
var material						fBlankKey;
var material						fKeyCap	;
var material						fBarCap	;
var material						fBarEnd	;
var material						fBarMid	;
var material						fProgBar;

var string							fKeyCode;
var EinputKey						fKeyDown;


var float							fByeByeTimer;
var bool							fCallUseAgain;
var bool							fPlayersHasKeyCode;
var bool							fPlayersKeysChecked;
var float							fPlayerHasKeyCodeTimer;
var string							fLocksKeyCode;
var float							fFlashingCursorTimer;
function Initialized()
{
	// does nothing here
	
}
function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	local int i;
	local B9_PlayerPawn PlayerPawn;


	Super.MenuInit(interaction,controller,parent);
	fPlayersHasKeyCode = false;
	fPlayersKeysChecked = false;
	fByeByeTimer = -1.0;
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	// If we are in ByeBye time, we no longer process input be we still return as if we handled it
	// If the fPlayerKeyCode is filled out then we don't accept info either instead we input the key for the player
	if(fByeByeTimer > 0 || fPlayersHasKeyCode ==  true)
		return true; 

	if(  Action == IST_Press && (Key == IK_Backspace || Key == IK_Escape ||
		Key == IK_RightMouse || Key == IK_Joy2) )
	{
		fKeyDown = IK_Backspace;
	//	RootController.PlaySound( fCancelSound );
		BeginByeByeTimer(0.0);
	}
	if( Action == IST_Press && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
	{
		if (fKeyDown == IK_None)
		{
			fKeyDown = IK_Up;
			AddToKeyCode("u");
		}
	}
	else if( Action == IST_Release && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
	{
		if (fKeyDown == IK_Up)
			fKeyDown = IK_None;
	}
	else if( Action == IST_Press && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
	{
		if (fKeyDown == IK_None)
		{
			fKeyDown = IK_Down;
			AddToKeyCode("d");
		}
	}
	else if( Action == IST_Release && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
	{
		if (fKeyDown == IK_Down)
			fKeyDown = IK_None;
	}
	else if( Action == IST_Press && (Key == IK_Left || Key == IK_Joy11) )
	{
		if (fKeyDown == IK_None)
		{
			fKeyDown = IK_Left;
			AddToKeyCode("l");
		}
	}
	else if( Action == IST_Release && (Key == IK_Left || Key == IK_Joy11) )
	{
		if (fKeyDown == IK_Left)
			fKeyDown = IK_None;
	}
	else if( Action == IST_Press && (Key == IK_Right || Key == IK_MouseWheelDown || Key == IK_Joy12) )
	{
		if (fKeyDown == IK_None)
		{
			fKeyDown = IK_Right;
			AddToKeyCode("r");
		}

	}
	else if( Action == IST_Release && (Key == IK_Right || Key == IK_MouseWheelDown || Key == IK_Joy12) )
	{
		if (fKeyDown == IK_Right)
			fKeyDown = IK_None;
	}
	return true;
}

function Tick( float Delta )
{
	local B9_PlayerPawn PlayerPawn;
	local int i;

	fFlashingCursorTimer += Delta;

	if( fFlashingCursorTimer > 1 )
	{
		fFlashingCursorTimer = 0;
	}

	if(fByeByeTimer >= 0.0)
	{
		fByeByeTimer = fByeByeTimer - Delta;
		if( fByeByeTimer <= 0 )
		{
			fByeByeTimer = -1.0;
			MenuExit();
			if( fCallUseAgain )
			{
				fCallUseAgain = false;
				RootController.use();
			}
		}
	}else if( fPlayersHasKeyCode )
	{
		fPlayerHasKeyCodeTimer = fPlayerHasKeyCodeTimer - Delta;
		if( fPlayerHasKeyCodeTimer < 0 )
		{
			fPlayerHasKeyCodeTimer = 0.5;
			AddToKeyCode(Mid(fLocksKeyCode,Len(fKeyCode),1));
		}
	}else if ( fPlayersKeysChecked == false && Len(fLocksKeyCode) > 0)
	{
		fPlayersKeysChecked = true;
		PlayerPawn = B9_PlayerPawn(RootController.pawn);
		if( PlayerPawn != None )
		{
			// Hard Coded NUMBER!
			// TODO Fix this
			for(i = 0; i < PlayerPawn.fKeyRingIndex ; i++)
			{
				log("Comparing Keys: "$PlayerPawn.fKeyRing[i]$" TO "$fLocksKeyCode);
				if( PlayerPawn.fKeyRing[i] == fLocksKeyCode )
				{
					log("Found a match");
					fPlayersHasKeyCode	= true;
					return;
				}
			}
		}
	}
}
function PostRender( canvas Canvas )
{
	local int index;
	local int x,y;
	local bool drewBarBegin;
	local int startOfBarsX,startOfBarsY;
	local int lengthOfDisplay;
	local int heightOfDisplay;

	lengthOfDisplay = ((64.0*float(Len(fLocksKeyCode))/2.0)-4)+ 16;
	heightOfDisplay = 32 + 16;
	drewBarBegin = false;
	x = Canvas.ClipX - lengthOfDisplay  - 32;
	y = Canvas.ClipY - heightOfDisplay - 32;

	// First Draw the End Caps
	Canvas.SetPos(x,y);
	Canvas.DrawTile( fKeyCap, 16, 32, 0, 0, 16, 32 );
	Canvas.SetPos(x,y+32);
	Canvas.DrawTile( fBarCap, 16, 16, 0, 0, 16, 16 );
	// Next Dr
	x = x + 16;
	startOfBarsX = x;
	startOfBarsY = y;
	// Finaly Draw Power Indicator
	if( Len(fLocksKeyCode) > 0)
	{
		Canvas.SetPos(startOfBarsX+2,startOfBarsY+35);
		Canvas.DrawTile( fProgBar, ((64.0*float(Len(fLocksKeyCode))/float(2))-4)*(float(Len(fKeyCode))/float(Len(fLocksKeyCode))), 16, 0, 0, 64, 16 );
	}
	Canvas.SetPos(startOfBarsX,startOfBarsY);


	// Next Draw out the code so far
	for( index = 0; index < Len(fKeyCode); index++)
	{
		if(Mid(fKeyCode,index,1) == "u")
		{
			Canvas.DrawTile( fUpDownKey, 32, 32, 0, 0, 32, 32 );
		}else if(Mid(fKeyCode,index,1) == "d")
		{
			Canvas.DrawTile( fUpDownKey, 32, 32, 0, 0, 32, -32 );
		}else if(Mid(fKeyCode,index,1) == "l")
		{
			Canvas.DrawTile( fLeftRightKey, 32, 32, 0, 0, -32, 32 );
		}else
		{
			Canvas.DrawTile( fLeftRightKey, 32, 32, 0, 0, 32, 32 );
		}
		// Draw Power Bar
		DrawPowerBars(Canvas,index,x,y);

		x = x + 32;
		Canvas.SetPos(x,y);
	}
	if(index < Len(fLocksKeyCode) )
	{
		if( fFlashingCursorTimer < 0.5 )
			Canvas.DrawTile( fCursorKey, 32, 32, 0, 0, 32, 32 );
		else
			Canvas.DrawTile( fBlankKey, 32, 32, 0, 0, 32, 32 );

		DrawPowerBars(Canvas,index,x,y);
		index++;
		x = x + 32;
		Canvas.SetPos(x,y);
		for( index = index; index < Len(fLocksKeyCode); index++)
		{
			if( fPlayersHasKeyCode == false)
			{
				Canvas.DrawTile( fBlankKey, 32, 32, 0, 0, 32, 32 );
			}else
			{
				DrawRandomDirectionKey(Canvas);
			}
			DrawPowerBars(Canvas,index,x,y);
			x = x + 32;
			Canvas.SetPos(x,y);
		}
	}

}

function DrawPowerBars(canvas Canvas,int index,int x, int y)
{
	if(index == 0  )
	{
		Canvas.SetPos(x,y+32);
		Canvas.DrawTile( fBarEnd, 16, 16, 0, 0, 16, 16 );
	}else
	{
		Canvas.SetPos(x,y+32);
		Canvas.DrawTile( fBarMid, 16, 16, 0, 0, 16, 16 );
	}

	if(index == (Len(fLocksKeyCode)-1))
	{
		Canvas.SetPos(x+16,y+32);
		Canvas.DrawTile( fBarEnd, 16, 16, 0, 0, -16, 16 );
	}else
	{
		Canvas.SetPos(x+16,y+32);
		Canvas.DrawTile( fBarMid, 16, 16, 0, 0, 16, 16 );
	}
}

function DrawRandomDirectionKey(canvas Canvas)
{
	local int RandomKeyCode;
	RandomKeyCode = Rand(4);
	if( RandomKeyCode == 0)
	{
		Canvas.DrawTile( fUpDownKey, 32, 32, 0, 0, 32, 32 );
	}else if( RandomKeyCode == 1)
	{
		Canvas.DrawTile( fUpDownKey, 32, 32, 0, 0, 32, -32 );
	}else if( RandomKeyCode == 2)
	{
		Canvas.DrawTile( fLeftRightKey, 32, 32, 0, 0, -32, 32 );
	}else
	{
		Canvas.DrawTile( fLeftRightKey, 32, 32, 0, 0, 32, 32 );
	}
}

function AddToKeyCode(string Key)
{
	fKeyCode = fKeyCode $ Key;
	if( Len(fKeyCode) == Len(fLocksKeyCode) )
	{
		// Done, submit the bad boy
		log("Submitting"$Key);
		B9_PlayerPawn(RootController.pawn).fUserInputKey = fKeyCode;
		BeginByeByeTimer(1.0);
		fCallUseAgain = true;
	}
}

function BeginByeByeTimer(float TimeToWait)
{
	fByeByeTimer = TimeToWait; 
}
function MenuExit()
{
	local B9_PlayerController pc;
	local int i;
	pc = B9_PlayerController(RootController);

	PopInteraction(pc, pc.Player);

}

defaultproperties
{
	fCursorKey=Texture'B9HUD_textures.code_hacking.code_hack_cursor'
	fUpDownKey=Texture'B9HUD_textures.code_hacking.code_hack_arrow_V'
	fLeftRightKey=Texture'B9HUD_textures.code_hacking.code_hack_arrow_H'
	fBlankKey=Texture'B9HUD_textures.code_hacking.code_hack_key'
	fKeyCap=Texture'B9HUD_textures.code_hacking.code_hack_key_cap'
	fBarCap=Texture'B9HUD_textures.code_hacking.code_hack_bar_cap'
	fBarEnd=Texture'B9HUD_textures.code_hacking.code_hack_bar_end'
	fBarMid=Texture'B9HUD_textures.code_hacking.code_hack_bar_mid'
	fProgBar=Texture'B9HUD_textures.code_hacking.code_hack_prog_bar'
	fByeByeTimer=-1
}