//=============================================================================
// B9_Conversation.uc
//
//  Base class for conversations
//  fStrings and fSounds contain the pieces of the conversation.
//  See "B9Game\Conversation_Example.uc" for an example.
//	
//=============================================================================


class B9_Conversation extends Actor
	notplaceable;

var array<sound>		fSounds;
var localized array<string>		fStrings;






defaultproperties
{
	DrawType=0
}