//=============================================================================
// skill_Hacking.uc
//
//	Hacking skill
//
//=============================================================================


class skill_Hacking extends B9_Skill; // B9_CharMod/Actor


//////////////////////////////////
// Resource imports
//
// Change this when we get the real textures
#exec OBJ LOAD FILE=..\textures\B9HUD_textures.utx PACKAGE=B9HUD_textures


//////////////////////////////////
// Definitions
//

enum eHackingStates
{
	skill_HackState_Idle,
	skill_HackState_Interogating,
	skill_HackState_Hacking
};
//////////////////////////////////
// Variables
//
var material						fCursorKey;
var material						fUpDownKey;
var material						fLeftRightKey;
var material						fBlankKey;
var material						fKeyCap	;
var material						fBarCap	;
var material						fBarEnd	;
var material						fBarMid	;
var material						fProgBar;

var string fPointingItem;
var Actor ActorBeingHacked;
var float fCurrentPercentageOfHackCompletion;

var float fHackRate;
var int fHackRank;
var int fChecks;
var bool fActorQueriedIsHackable ; // This is ONLY set to true immediatly after the trigger request.  Do not test this variable at any other time
var eHackingStates fSkillState;
var float fEstimatedTimeToHack;
var float fMaxHackTime;
var float fEstimatedTimeToInterogate;
var public bool fInterrogationSuccess;
var bool	fLoadedFonts;
var font 		fHackFont24;
var font 		fHackFont16;
var sound		fSuccessInterogation;
var sound		fFailedInterogation;
var sound		fFinishedHack;	
var sound		fHaltedHack;
var bool		bLeaveActiveState;
var NanoFX_Hacking		fFX;
var sound		HackingAmbient;
var sound		HackingFailed;
var sound		HackingStart;
var sound		HackingSuccess;
var sound		HackingSuccess2;
var sound		HackingHalt ;

var string fKeyCode;


var() localized string B9Fonts;

var() localized string MSA24Font;
var() localized string MSA16Font;
var	  int HealthAtStartOfHack;
var float	fTimeUntilNextCheck;
replication
{
	// Things the server should send to the client.
	reliable if( Role == ROLE_Authority )
		fPointingItem,ActorBeingHacked,fCurrentPercentageOfHackCompletion,
		fSkillState,fEstimatedTimeToInterogate ,fEstimatedTimeToHack,fMaxHackTime,
		bLeaveActiveState,fKeyCode;
	reliable if( Role < ROLE_Authority )
		PawnStopHacking,ServerFindClosestHackable,ServerInterrogatingTick,ServerHackingTick;
}
//////////////////////////////////
// Functions
//
function PostBeginPlay()
{
}

function PawnStopHacking( )
{
	B9_AdvancedPawn( Owner ).StopPlayHacking();

	if ( fFX != None )
	{
		fFX.Destroy();
		fFX = None;
  		AmbientSound = None;
	}
}

event Destroyed()
{
	if ( fFX != None )
	{
		fFX.Destroy();
		fFX = None;
	}

	Super.Destroyed();
}

function ServerActivate()
{
	local B9_AdvancedPawn	P;	
	local Controller		C;

	
	fSkillState = skill_HackState_Interogating;
	fEstimatedTimeToInterogate = +5.1;

	if( !CheckFocus() )
	{
		return;
	}

	P = B9_AdvancedPawn( Owner );
	P.PlayHacking();
	if ( fFX == None )
	{
		fFX	= Spawn( class'NanoFX_Hacking', Self, , Owner.Location, Owner.Rotation );
		P.AttachToBone( fFX, 'NanoBone' );
	}

	fFocusUseTimer=0.0;
	bLeaveActiveState = false;
//	HealthAtStartOfHack = Owner.Health;

}

simulated function Activate()
{
	ServerActivate();

	GotoState('Active');
}

function ServerFindClosestHackable(bool Hackit)
{
	local Actor targetPawn;
	local float rangeToTarget;
	local float closestRangeToTarget;
	local Actor closestActor; 
	local int Action;


	fPointingItem = "";
	closestActor = none;
	closestRangeToTarget = 300;
	if( Pawn(  Owner ) != none )
	{
		ForEach Pawn(  Owner ).VisibleCollidingActors( class'Actor',targetPawn, 300.0f )
		{
			if( targetPawn != none)
			{
			   //log("At least one TargetPawn!"$targetPawn);
				Action	= targetPawn.GetHUDActions( Pawn( Owner ) );
				if( (Action & kHUDAction_Hack )!= 0 )
				{
//					log("At least on Hackable item in Range!");
					fSkillMode = skillMode_RequestingHackRank;
					fActorQueriedIsHackable = false; // Make sure we get a responce
					targetPawn.Trigger( self,  Pawn(  Owner ) );
					if( fActorQueriedIsHackable )
					{
						rangeToTarget = VSize( Pawn(  Owner ).Location - targetPawn.Location );
						if( rangeToTarget < closestRangeToTarget  && (Pawn(  Owner ) != targetPawn) )
						{
							closestActor = targetPawn;
						}
					}
				}
			}
		}
		if( closestActor != none )
		{
			fPointingItem = closestActor.GetHumanReadableName();
			if( Hackit )
			{
				if( ActorBeingHacked == none )
				{
					fSkillMode = skillMode_Hacking;
					closestActor.Trigger( self,  Pawn(  Owner ) );
					ActorBeingHacked = closestActor;

				}else if ( ActorBeingHacked != closestActor )
				{
					fSkillMode = skillMode_StoppedHacking;
					ActorBeingHacked.Trigger( self,  Pawn(  Owner ) );
					ActorBeingHacked = none;

					PawnStopHacking(  );
					LeaveActiveState();
				}
			}
		}else if( ActorBeingHacked != none )
		{
			ActorBeingHacked = none;
		}else
		{
//			log("No Closest Hackable actor found");
		}
	}else
	{
		ActorBeingHacked = none;
	}
	if( ActorBeingHacked == None  && Hackit == true)
	{
		LeaveActiveState();
	}
}
function int FinalSkillStrength()
{
		local B9_AdvancedPawn		advPawn;
		local int dex;
		dex = fStrength;

		advPawn			= B9_AdvancedPawn( Owner );
		if( advPawn != none )
		{
			dex = fStrength + advPawn.fCharacterDexterity;
		}
		return dex;
}

function float GetHackTime()
{
	local int  Rank;
	local float hackTime;
	Rank = fHackRank;
	// Negative Ranks imply that they have been hacked already
	if( Rank < 0 )
	{
		Rank = Rank * -1;
	}
	hackTime = (+5.0 * ( float( Rank ) / float( FinalSkillStrength()) )) * 4;
	if ( hackTime < 2.0 )
	{
		hackTime = 2.0;
	}

	return hackTime;
}

// In this case we use numericData for the Hacking Rating of the actor
function int SkillFeedBack( Actor interactingActor, eSkillResponseCodes ResponseCode, int numericData, string KeyCode)
{
	if( ResponseCode == skillResponse_ThisIsMyRank )
	{
		fActorQueriedIsHackable = true;
//		log("Hack rank is "$numericData);
		fHackRank			= numericData;
		fLocksKeyCode		= KeyCode;
	}else if( ResponseCode == skillResponse_BeingHacked )
	{
		fEstimatedTimeToInterogate = 0.1f;
	}else if( ResponseCode == skillResponse_StoppedHacking )
	{
		if( fInterrogationSuccess == true)
		{
			return 1;
		}
	}
	return 0;
}

function IdleTick( float DeltaTime )
{

}
simulated function font LoadFont( String fontName )
{
	return font( DynamicLoadObject( B9Fonts $ fontName, class'Font' ) );
}
function Tick( float DeltaTime )
{

	IdleTick( DeltaTime );
}

function	HackTheActor()
{
	if( ActorBeingHacked != none )
	{
		fSkillMode = skillMode_Hacked;
		ActorBeingHacked.Trigger( self,  Pawn(  Owner ) );
		
		ActorBeingHacked.PlaySound( HackingSuccess );
	}else
	{
//		log("No Actor!");
	}
}

simulated function DebugDisplayNearestHackableItem( canvas Canvas )
{
	local color red;
	local font oldFont;

	oldFont = Canvas.Font;
	
	red.R = 255;
	red.G = 0;
	red.B = 0;
	Canvas.SetPos( 150, 150);
	Canvas.SetDrawColor(red.R, red.G, red.B);
	Canvas.DrawText( fPointingItem, false );
	Canvas.Font = oldFont;
}

simulated function DisplayIdleGraphics( canvas Canvas )
{
	local font oldFont;
	local color red;
	oldFont = Canvas.Font;
	

	red.R = 255;
	red.G = 0;
	red.B = 0;
	Canvas.SetPos( 150, 160);
	Canvas.SetDrawColor(red.R, red.G, red.B);
	Canvas.DrawText( "Idle", false );
	Canvas.Font = oldFont;
}

simulated function DisplayInterrogatingGraphics( canvas Canvas )
{
	local color green;
	local font oldFont;
	local string DisplayString;
	local string EstimationString;
	
	local float sx,sy;
	local float drawPointX,drawPointY;
	

	DisplayString = "Interrogating System";
	EstimationString = "Estimated time until hack key found:";
	oldFont = Canvas.Font;
	Canvas.Font = fHackFont24;
	green.R = 0;
	green.G = 255;
	green.B = 0;
	drawPointX = Canvas.ClipX*0.1875;
	drawPointY = Canvas.ClipY*0.75;

	Canvas.SetPos( drawPointX , drawPointY );
	Canvas.SetDrawColor(green.R, green.G, green.B);
	Canvas.DrawText( DisplayString, false );
	Canvas.TextSize(DisplayString,sx,sy);
	drawPointY = drawPointY + sy;
	Canvas.SetPos(  drawPointX , drawPointY);
	EstimationString = EstimationString$string(fEstimatedTimeToInterogate);
	Canvas.TextSize(EstimationString,sx,sy);

	Canvas.DrawText( EstimationString , false );
	drawPointY = drawPointY + sy;
	Canvas.SetPos(  drawPointX , drawPointY);
	Canvas.Font = fHackFont16;

	DisplayString = GetFakeHackAlgorithm();
	Canvas.DrawText(DisplayString, false );
	Canvas.Font = oldFont;
}

simulated function string GetFakeHackAlgorithm()
{
	if( fHackRank < 0 )
	{
		return "Using stored algorithm. One moment please";
	}else
	{
		return "Scanning for Optimum crack method. INDEX:"$Rand(10)$Rand(10)$Rand(10)$"-"$Rand(10)$Rand(10)$":"$Rand(10)$Rand(10)$Rand(10)$Rand(10)$Rand(10);
	}
}

	
simulated function string GetHackingStageText()
{
	if( fInterrogationSuccess == true)
	{
		return "InteleHack? bypass detection successful";
	}else
	{
		return "InteleHack? bypass detection unsuccessful";
	}
}

simulated function string GetHackingProcessText()
{
	if( fInterrogationSuccess == true)
	{
		return "Using InteleHack? security bypass methods";
	}else
	{
		return "Using Brut-force? security bypass methods";
	}
}

simulated function DisplayHackingGraphics( canvas Canvas )
{
	local material progressBarTex;
	local float barProgress;

	// The following vars will be read in from an .ini file they are used to offset the HUD when 
	// running on a Television system
	local int pixelsFromTop;
	local int pixelsFromLeft;

	local float sx,sy;
	local float drawPointX,drawPointY;
	local string DisplayString;

	local color green;
	local color red;
	local font oldFont;


	oldFont = Canvas.Font;
	Canvas.Font = fHackFont24;
	drawPointX = Canvas.ClipX*0.1875;
	drawPointY = Canvas.ClipY*0.75;

	green.R = 0;
	green.G = 255;
	green.B = 0;

	red.R  = 255;
	red.G  = 0;
	red.B  = 0;


	// This will color the Text AND the Bar
	if( fInterrogationSuccess == true)
	{
		Canvas.SetDrawColor(green.R, green.G, green.B);
	}else
	{
		Canvas.SetDrawColor(red.R, red.G, red.B);
	}

	Canvas.SetPos( drawPointX , drawPointY );
	//"Hacking"$string(fEstimatedTimeToHack) 
	DisplayString = GetHackingStageText();

	Canvas.TextSize(DisplayString,sx,sy);
	Canvas.DrawText( DisplayString, false );
	drawPointY = drawPointY + sy;
	Canvas.SetPos(  drawPointX , drawPointY);
	Canvas.Font = fHackFont16;

	DisplayString = GetHackingProcessText();
	Canvas.DrawText(DisplayString , false );



	// If the res is small, then we adjust the hud items to be farther away from the edge of the screen
	// The small rez. inferse that the display device is a TV, and thus needs to display info in the safe zone.
	if( Canvas.ClipX < 600 )
	{
		pixelsFromLeft = 200;
		pixelsFromTop = 200; 
	}else
	{
		pixelsFromLeft = 200;
		pixelsFromTop  = 200; 
	}




	///////////////////////////////////////
	// setup Textures
	progressBarTex				= material'B9HUD_textures.health_and_focus.health_gauge_tl';
	barProgress		= 128 * ( fEstimatedTimeToHack / fMaxHackTime );




	// Draw Health Bars
	Canvas.SetPos( pixelsFromLeft , pixelsFromTop  );
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawTileClipped(progressBarTex , barProgress, 16, 0, 0, 128, 16 );

	Canvas.Font = oldFont;

}
	
function ServerInterrogatingTick( float DeltaTime )
{
	if( ActorBeingHacked != None )
	{
		/*
		if( HealthAtStartOfHack > Owner.Health )
		{
			// Player has been wounded, stop hacking
			LeaveActiveState();
			return;
		}
		*/
		fEstimatedTimeToInterogate -= DeltaTime;
		if( fEstimatedTimeToInterogate <= 0.0 )
		{
			fSkillState = skill_HackState_Hacking;
			
			fEstimatedTimeToHack = GetHackTime() ;
			if( fHackRank < 0 || Rand(fHackRank)*1.5 < FinalSkillStrength() )
			{
				Owner.PlaySound( HackingSuccess2 );
				fInterrogationSuccess = true;
				// Speed Increased for E3, final speed as yet to be determined
				fHackRate = 3.0f;
				//fHackRate = 0.30f;
			}else
			{
				Owner.PlaySound( HackingFailed, SLOT_None, 1.0,, 200 );
				fHackRate = 1.0f;
				// Speed Increased for E3, final speed as yet to be determined
				//fHackRate = 0.10f;
				fInterrogationSuccess = false;
			}
			fMaxHackTime         = fEstimatedTimeToHack;
		}
  		fFocusUseTimer += DeltaTime;
  		if( fFocusUseTimer >= fTimeBetweenFocusUses )
  		{
  			UseFocus();
  			fFocusUseTimer = 0.0;
  		}
	}else
	{
//		log("ServerInterrogatingTick No Actor!");
	}
}

function ServerHackingTick( float DeltaTime )
{
	if( ActorBeingHacked != None )
	{
		
		fEstimatedTimeToHack -= (DeltaTime*fHackRate);
		if( fEstimatedTimeToHack <= 0.0 )
		{
			HackTheActor();
			LeaveActiveState();
		}
	}else
	{
//		log("ServerHackingTick No Actor!");
	}
}

function LeaveActiveState()
{
	bLeaveActiveState = true;
}

//////////////////////////////////
// States
//

state Active
{
	function Activate(); // Do nothing in this state

	function BeginState();

	simulated function EndState()
	{
		fCurrentPercentageOfHackCompletion = 0.0;
		fHackRate = 0;
		fHackRank = 0;
		fChecks = 0;
		if( (fSkillState == skill_HackState_Interogating || fSkillState == skill_HackState_Hacking ) && ActorBeingHacked != none) // This means we were hacking but we were interupted before we finished.
		{
			fSkillMode = skillMode_StoppedHacking;
			ActorBeingHacked.Trigger( self,  Pawn(  Owner ) ); // let the actor we were hacking know we stopped.
			Owner.PlaySound( HackingHalt );
		}
		fCurrentPercentageOfHackCompletion = 0;
		ActorBeingHacked = none;
		fHackRank = 0;
		fChecks = 0;
		fSkillState = skill_HackState_Idle;

		PawnStopHacking(  );
	}

	simulated event RenderOverlays( canvas Canvas )
	{
		//DebugDisplayNearestHackableItem( Canvas );
		
		if( fLoadedFonts == false)
		{
			fHackFont24 = font(DynamicLoadObject( B9Fonts $ MSA24Font, class'Font' ));
			fHackFont16 = font(DynamicLoadObject( B9Fonts $ MSA16Font, class'Font' ));
			fLoadedFonts = true;
		}

		switch( fSkillState )
		{
			case skill_HackState_Idle:
					// DisplayIdleGraphics( Canvas );
				break;
			case skill_HackState_Interogating:
					//DisplayInterrogatingGraphics( Canvas );
				break;
			case skill_HackState_Hacking:
					//DisplayHackingGraphics( Canvas );
					DisplayNewHackingGraphics( Canvas );
				break;
		}
	}
	




	simulated function Tick( float DeltaTime )
	{
		local B9_AdvancedPawn		OwnerPawn;
		local bool					kOKToUse;	// need this because GotoState('') isn't immediate
		local B9_PlayerPawn			PlayerPawn;

		if( bLeaveActiveState == true )
		{
			
			GotoState('');
			return;
		}


		kOKToUse	= true;
		OwnerPawn			= B9_AdvancedPawn( Owner );
		
		fTimeUntilNextCheck = fTimeUntilNextCheck - DeltaTime;
		
//		if( fTimeUntilNextCheck <= 0)
//		{
//			fTimeUntilNextCheck = 0.25f;
			ServerFindClosestHackable(true);
//		}
		
		switch( fSkillState )	    
		{
			case skill_HackState_Idle:
				break;		
			case skill_HackState_Interogating:
				ServerInterrogatingTick( DeltaTime );
				break;
			case skill_HackState_Hacking:
				ServerHackingTick( DeltaTime );
				break;
		}
	}
}

// Note this was ripped driectly from PostRender of the KeyInput Menu to unify the look of hacking with the new key entry system

simulated function DisplayNewHackingGraphics( canvas Canvas )
{
	local int index;
	local int x,y;
	local bool drewBarBegin;
	local int startOfBarsX,startOfBarsY;
	local int lengthOfDisplay;
	local int heightOfDisplay;
	local float progress;
	local float nextLevel;

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
	progress = 1.0-(fEstimatedTimeToHack / fMaxHackTime);
	nextLevel =  (float( Len(fKeyCode)) + 1.0 )/ float(Len(fLocksKeyCode));
	if( Len(fLocksKeyCode) > 0)
	{
		Canvas.SetPos(startOfBarsX+2,startOfBarsY+35);
		Canvas.DrawTile( fProgBar, ((64.0*float( Len(fLocksKeyCode))/2.0 )-4)*(1.0-(fEstimatedTimeToHack / fMaxHackTime)), 16, 0, 0, 64, 16 );
	}

	if(progress > nextLevel)
	{
		AddToKeyCode(Mid(fLocksKeyCode,Len(fKeyCode),1));
	}
	Canvas.SetPos(startOfBarsX,startOfBarsY);


	// Next Draw out the code so far
	// Not used in this code yet.
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
		DrawRandomDirectionKey(Canvas);
		DrawPowerBars(Canvas,index,x,y);
		index++;
		x = x + 32;
		Canvas.SetPos(x,y);
		for( index = index; index < Len(fLocksKeyCode); index++)
		{
			DrawRandomDirectionKey(Canvas);
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

simulated function DrawRandomDirectionKey(canvas Canvas)
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

simulated function AddToKeyCode(string Key)
{
	fKeyCode = fKeyCode $ Key;
	if( Len(fKeyCode) == Len(fLocksKeyCode) )
	{
		// Done, submit the bad boy
	}
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
	fHackRate=1
	fHackRank=1
	fSuccessInterogation=Sound'B9SoundFX.Menu.ok_1'
	fFailedInterogation=Sound'B9SoundFX.Menu.cancel_2'
	fFinishedHack=Sound'B9SoundFX.Menu.ok_1'
	fHaltedHack=Sound'B9SoundFX.Menu.cancel_2'
	HackingAmbient=Sound'B9Skills_sounds.Hacking.hacking_code_loop1'
	HackingFailed=Sound'B9Skills_sounds.Hacking.hacking_code_wrong2'
	HackingStart=Sound'B9Skills_sounds.Hacking.hacking_code_lock1'
	HackingSuccess=Sound'B9Skills_sounds.Hacking.hacking_code_success1'
	HackingHalt=Sound'B9Skills_sounds.Hacking.hacking_code_wrong1'
	B9Fonts="B9_Fonts."
	MSA24Font="MicroscanA24"
	MSA16Font="MicroscanA16"
	fActivatable=true
	fSkillName="Hacking"
	fUniqueID=2
	fSkillType=1
	fFocusUsePerActivation=1
	fTimeBetweenFocusUses=0.1
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.Hacking_bricon'
}