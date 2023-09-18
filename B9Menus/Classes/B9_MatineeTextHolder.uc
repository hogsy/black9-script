// B9_MatineeTextHolder

class B9_MatineeTextHolder extends Actor
	placeable;

enum DialogueSpeaker
{
	// Non-interactive options
	DS_PC,
	DS_NPC,
	DS_LETTERBOX,

	// A break between dialogue sets
	DS_STOP,			// Don't know if this is needed.

	// Interactive options
	DS_PC_MORE,
	DS_NPC_MORE,
	DS_PC_DONE,
	DS_NPC_DONE,
	DS_YESNO,
	DS_NPC_QUERY,
	DS_PC_CHOICE,		// Two or more choices in a row after a DS_NPC_QUERY.

	DS_SKIP,
};

struct DialogueInfo
{
	var() string Text;
	var() DialogueSpeaker Speaker;
	var() sound Voice;
};

var(MatineeTextHolder) int TextIndex;
var(MatineeTextHolder) localized array<DialogueInfo> MatineeText;

var transient B9_MenuInteraction MenuInteractionFactory;
var transient B9_MatineeTextInteraction MatineeInteraction;
var B9_PlayerController PlayerController;

var bool bDialogueShown;
var B9_AdvancedPawn fActionInstigator;
var bool bOldBehindView;
var int fFaceToFace;
var B9_PlayerPawn fPlayerPawn;

var class<B9_MenuInteraction>	MenuClass;
var class<B9_MenuInteraction>	FactoryClass;

event Trigger( Actor Other, Pawn Instigator )
{
	local B9_MatineeTextReset reset;
	local SceneManager SM;

	fActionInstigator = None;

	ForEach AllActors(class'B9_PlayerController', PlayerController)
	{
		break;
	}

	// Check for trigger from B9_MatineeTextReset.
	reset = B9_MatineeTextReset(Other);
	if (reset != None)
	{
		TextIndex = reset.TextHolderIndex;
		if (bDialogueShown)
			HideDialogue();
		return;
	}

	// Check for NPC activation.
	fActionInstigator = B9_AdvancedPawn(Other);
	fPlayerPawn = B9_PlayerPawn(Instigator);
	if (fActionInstigator != None && fPlayerPawn != None)
	{
		fFaceToFace = 0;
		TextIndex = fActionInstigator.DialogueInit(fFaceToFace);

		if (!bDialogueShown)
		{
			while (TextIndex < MatineeText.Length)
			{
				if (MatineeText[TextIndex].Speaker != DS_SKIP)
				{
					if (fFaceToFace != 0)
						MakeFaceToFace(Instigator);

					ShowDialogue();
					return;
				}
				++TextIndex;
			}

			// oops!
			Log(self@"No text left!");
		}
		else Log(self@"Already in dialogue!");
		return;
	}

	// Assume matinee sub action or just test code using trigger.
	//if (Controller(Other) != None || Triggers(Other) != None)
	//{

		// !!!! It is not entirely obvious what class Other may be in the case of a matinee.
		//		Known possibilities are ScriptedSequence and PlayerController, but there may
		//		be more. So for now I just assume if the code gets to this point, this was
		//		triggered by a matinee.

		if (bDialogueShown)
		{
			HideDialogue();
			++TextIndex;
			return;
		}
		
		while (TextIndex < MatineeText.Length)
		{
			if (MatineeText[TextIndex].Speaker != DS_SKIP)
			{
				ForEach PlayerController.AllActors( class'SceneManager', SM )
				{
					if (SM.bIsSceneStarted)
					{
						fPlayerPawn = B9_PlayerPawn(SM.OldPawn);
						break;
					}
				}

				ShowDialogue();
				return;
			}
			++TextIndex;
		}

		// oops!
		Log(self@"No text left!");
		return;
	//}

	//Log(Other@"Tried to activate B9_MatineeeTextHolder");
}

function MakeFaceToFace(Pawn TalkTo)
{
	local vector v;
	local rotator r1, r2;
	local MenuUtility utils;

	// at this point "v" should be (0,0,0)
	fActionInstigator.Acceleration = v;
	fActionInstigator.Velocity = v;

	TalkTo.Acceleration = v;
	TalkTo.Velocity = v;

	bOldBehindView = PlayerController.bBehindView;
	PlayerController.BehindView(false);

	v = TalkTo.Location - fActionInstigator.Location;
	r1 = PlayerController.GetEularAngles( v );
	r2 = fActionInstigator.Rotation;
	r2.Yaw = r1.Yaw;
	fActionInstigator.SetRotation( r2 );

	v = -v;
	r1 = PlayerController.GetEularAngles( v );
	r2 = TalkTo.Rotation;
	r2.Yaw = r1.Yaw;
	TalkTo.SetRotation( r2 );

	utils = new(None) class'MenuUtility';
	utils.ResetInput(PlayerController);
}

function ShowDialogue()
{
	local Interaction ia;

	if (MenuInteractionFactory == None)
		MenuInteractionFactory = new(None) FactoryClass;

	ia = MenuInteractionFactory.PushInteraction(MenuClass, PlayerController, PlayerController.Player);
	MatineeInteraction = B9_MatineeTextInteraction(ia);
	MatineeInteraction.SetHolder(self);

	bDialogueShown = true;
}

function HideDialogue()
{
	MatineeInteraction.CloseDialogue();
	
	MatineeInteraction.PopInteraction(PlayerController, PlayerController.Player);

	MatineeInteraction = None;
	bDialogueShown = false;

	if (fFaceToFace != 0)
	{
		PlayerController.BehindView(bOldBehindView);
	}
}

function UserResponce(int i)
{
	local DialogueSpeaker spkr;
	
	spkr = MatineeText[TextIndex].Speaker;

	if (spkr == DS_PC_MORE || spkr == DS_NPC_MORE)
	{
		if (i == 0)
		{
			++TextIndex;
			spkr = DS_STOP;
			while (TextIndex < MatineeText.Length)
			{
				spkr = MatineeText[TextIndex].Speaker;
				if (spkr != DS_SKIP)
					break;
				++TextIndex;
				spkr = DS_STOP;
			}

			if (spkr == DS_PC_MORE || spkr == DS_NPC_MORE ||
				spkr == DS_PC_DONE || spkr == DS_NPC_DONE ||
				spkr == DS_NPC_QUERY || spkr == DS_YESNO)
			{
				MatineeInteraction.SetHolder(self);
				return;
			}
		
			i = -1;
		}

		HideDialogue();
		spkr = DS_STOP;
		while (TextIndex < MatineeText.Length)
		{
			spkr = MatineeText[TextIndex].Speaker;
			if (spkr == DS_PC_DONE || spkr == DS_NPC_DONE || spkr == DS_STOP ||
				spkr == DS_NPC_QUERY || spkr == DS_YESNO)
				break;
			++TextIndex;
			spkr = DS_STOP;
		}
		
		if (spkr == DS_NPC_QUERY || spkr == DS_YESNO)
		{
			MatineeInteraction.SetHolder(self);
		}
		else if (fActionInstigator != None)
		{
			if (TextIndex < MatineeText.Length)
				++TextIndex;
			fActionInstigator.DialogueResult(i, TextIndex);
		}
	}
	else if (spkr == DS_PC_DONE || spkr == DS_NPC_DONE)
	{
		HideDialogue();
		++TextIndex;
		if (fActionInstigator != None)
			fActionInstigator.DialogueResult(0, TextIndex);
	}
	else if (spkr == DS_NPC_QUERY)
	{
		HideDialogue();
		++TextIndex;
		while (TextIndex < MatineeText.Length)
		{
			if (MatineeText[TextIndex].Speaker != DS_PC_CHOICE)
				break;
			++TextIndex;
		}
		if (fActionInstigator != None)
			fActionInstigator.DialogueResult(i, TextIndex);
	}
	else if (spkr == DS_YESNO)
	{
		HideDialogue();
		++TextIndex;
		if (fActionInstigator != None)
			fActionInstigator.DialogueResult(i, TextIndex);
	}
}

defaultproperties
{
	MenuClass=Class'B9_MatineeTextInteraction'
	FactoryClass=Class'B9BasicTypes.B9_MenuInteraction'
	bHidden=true
}