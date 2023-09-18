//=============================================================================
// B9_Conversation_Actor.uc
//
// 
//=============================================================================


class B9_Conversation_Actor extends B9_Special_Level_Objects
	placeable;


var(B9_Conversation_Actor) class<B9_Conversation> fConversationClass;
var(B9_Conversation_Actor) bool fAudioOnly;
var B9_Conversation fConversation;
var B9_PlayerPawn	fPlayer;
var (B9_Conversation_Actor) string fTravelToMap;
var (B9_Conversation_Actor) bool fEnteringMission;
//Boolean determining whether or not to play the sound from a specific location 
//or sending it to the characters headset(not real player headset)
var (B9_Conversation_Actor) bool fLocationIndependent;

var bool	fFinished;
var int		fConvoIndex;
var float	fCurrentVOLength;
var float	fSampleTimer;
var bool	fPlaying;
const		kSampleSpacer = 1.0;
const		kEndOfConversationLinger = 3.5;

function Trigger( actor Other, pawn EventInstigator )
{
	
	fPlayer = B9_PlayerPawn( EventInstigator );
	if( fPlayer == None )
	{
		return;
	}

	GotoState( 'StartTalking' );
	
	/*
	if( !fFinished  )
	{
        GotoState( 'StartTalking' );
	}
	*/
}

function UnTrigger( actor Other, pawn EventInstigator )
{
	//fFinished = true;
}


simulated state StartTalking
{
	function Trigger( actor Other, pawn EventInstigator ) {}
	function UnTrigger( actor Other, pawn EventInstigator )
	{
		//DoneTalking();
	}

	simulated function Tick( float Delta )
	{
		
		if( fPlaying )
		{
			fSampleTimer += Delta;
			if( fSampleTimer >= 5.0 )
			{
				fPlaying			= false;
				fSampleTimer		= 0.0;
				fCurrentVOLength	= 0.0;
				PlayNext();
			}
		}	
		
	}

	simulated function BeginState()
	{
		local B9_HUD				b9hud;
		local B9_PlayerController	C;
		if( fConversationClass == None )
		{
			DoneTalking();
			return;
		}
		fConversation = Spawn( fConversationClass, self );

		if( !fAudioOnly )
		{
			if( fPlayer != None )
			{
				C = B9_PlayerController( fPlayer.Controller );
				if( C != None )
				{
					b9hud = B9_HUD( C.myHUD );
					if( b9hud != None && !b9hud.IsConversationPanelVisible() )
					{
						b9hud.ShowConversationPanel( true );
					}
				}
			}
		}
	}

	simulated function NextString()
	{
		local B9_HUD				b9hud;
		local B9_PlayerController	C;

		if( fPlayer != None )
		{
			C = B9_PlayerController( fPlayer.Controller );
			if( C != None )
			{
				b9hud = B9_HUD( C.myHUD );
				if( b9hud != None )
				{
					b9hud.AddStringToConversation( fConversation.fStrings[ fConvoIndex ] );
				}
			}
		}
	}

	simulated function NextSound()
	{
		fCurrentVOLength = GetSoundDuration( fConversation.fSounds[ fConvoIndex ] );

		if( fConvoIndex + 1 == fConversation.fSounds.Length )
		{
			fCurrentVOLength += kEndOfConversationLinger;
		}
		else
		{
            fCurrentVOLength += kSampleSpacer;
		}
		if(fLocationIndependent == true)
		{
           PlayOwnedSound( fConversation.fSounds[ fConvoIndex ], SLOT_Interface, 1.0, true, 200 ); 
		}
		else
		{
			PlayOwnedSound( fConversation.fSounds[ fConvoIndex ], SLOT_Talk, 1.0, true, 200 );
		}
		
		
		fPlaying = true;
		fConvoIndex++;
	}


	simulated function PlayNext()
	{
		///Temp Fix so that the conversations work even though 
		// we dont have the sounds. 
		// If you leave the fSounds[x] = Sound'None' UCC warns you about it. 

		//if( fConvoIndex == fConversation.fSounds.Length  || 
		//	fConvoIndex == fConversation.fStrings.Length )

		if(fConvoIndex == fConversation.fStrings.Length )
		{
			DoneTalking();
			return;
		}

		if( !fAudioOnly )
		{
            NextString();
		}
		NextSound();
	}

	simulated function DoneTalking()
	{
		local B9_HUD				b9hud;
		local B9_PlayerController	C;

		if( !fAudioOnly )
		{
			if( fPlayer != None )
			{
				C = B9_PlayerController( fPlayer.Controller );
				if( C != None )
				{
					b9hud = B9_HUD( C.myHUD );
					if( b9hud != None )
					{
						b9hud.ShowConversationPanel( false );
					}
				}
			}
		}
		
		fConvoIndex = 0;
		fFinished = true;
		if (fEnteringMission)
			fPlayer.SetupForMission();
		if (Len(fTravelToMap) > 0)
			PlayerController(fPlayer.Controller).ClientTravel(fTravelToMap, TRAVEL_Absolute, true );
		GotoState( '' );
	}

Begin:

	PlayNext();
}



defaultproperties
{
	bHidden=true
}