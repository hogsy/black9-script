//=============================================================================
// B9_Conversation_Actor_Player.uc
//
// 
//=============================================================================


class B9_Conversation_Actor_Player extends B9_Conversation_Actor
	placeable;
	
/////////////////////////////////
// Christian Rickeby
// Holds the 4 different conversations
//
var(B9_Conversation_Actor) class<B9_Conversation> fSaharaClass;
var(B9_Conversation_Actor) class<B9_Conversation> fJakeClass;
var(B9_Conversation_Actor) class<B9_Conversation> fGruberClass;
var(B9_Conversation_Actor) class<B9_Conversation> fYlsaClass;



function Trigger( actor Other, pawn EventInstigator )
{
	fPlayer = B9_PlayerPawn( EventInstigator );
	if( fPlayer != None )
	{
		/////////////////////////////////
		// Christian Rickeby
		// Find which character the player is using
		// and set the right conversation
		//
		if(fPlayer.IsA('B9_player_norm_female'))
		{
			fConversationClass = fSaharaClass;
		}
		if(fPlayer.isa('B9_player_norm_male'))
		{
			fConversationClass = fJakeClass;
		}
		if(fPlayer.isa('B9_player_mutant_female'))
		{
			fConversationClass = fYlsaClass;
		}
		if(fPlayer.isa('B9_player_mutant_male'))
		{
			fConversationClass = fGruberClass;
		}
		
		if(fConversationClass == None)
		{
			return;
		}
	}
	else
	{
		return;
	}

	GotoState( 'StartTalking' );
	/*if( !fFinished  )
	{
        GotoState( 'StartTalking' );
	}
	*/
}
