/////////////////////////////////////////////////////////////
// B9_MM_MultiPlayer_DeleteCharactersMenu
//
// Player must choose which of their characters they wish to delete
// This is CURRENTLY a debug menu.

class B9_MM_MultiPlayer_DeleteCharactersMenu extends B9_MM_SimpleListMenu;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Initialized()
{
	log(self@"I'm alive");

	fHasGoBack = true;
}


function InitHandlers( PlayerController controller )
{
	if ( fCharacterManager == None )
	{
		ForEach controller.AllActors( class'B9_CharacterManager', fCharacterManager )
		{
			break;
		}

		if ( fCharacterManager == None )
		{
			fCharacterManager = controller.Spawn( class'B9_CharacterManager' );
		}
	}
}


function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit( interaction, controller, parent );

	InitHandlers( controller );

	RefreshMenus();
}


function RefreshMenus()
{
	local SimpleItemInfo info;
	local SimpleImageInfo img;
	local int x;
	local int y;
	local int yOffset;
	local int yImageOffset;
	local int i;

	x = 43;
	y = 281;
	yOffset = 40;
	yImageOffset = 60;

	fItemArray.Length = fCharacterManager.fCharacterCount;

	for ( i = 0; i < fCharacterManager.fCharacterCount; i++ )
	{
		fItemArray[ i ].X = x;
		fItemArray[ i ].Y = y;
		fItemArray[ i ].Label = "Delete " $ fCharacterManager.fCharacters[ i ].fName;

		y += yOffset;
	}

	y += yImageOffset - yOffset;


	fImageArray.Length = 4;

	img.X = 64;
	img.Y = 203;
	img.Image = texture'B9Menu_Tex_std.mp_title_left';
	fImageArray[0] = img;

	img.X = 320;
	img.Y = 203;
	img.Image = texture'B9Menu_Tex_std.mp_title_right';
	fImageArray[1] = img;

	img.X = 64;
	img.Y = y;
	img.Image = texture'B9MenuHelp_Textures.choice_select';
	fImageArray[2] = img;

	img.X = 320;
	img.Y = y;
	img.Image = texture'B9MenuHelp_Textures.choice_back';
	fImageArray[3] = img;

	Super.Initialized();
}


function ClickItem()
{
	if ( fKeyDown != IK_Backspace )
	{
		// Delete selection
		fCharacterManager.DeleteCharacter( fSelItem );
	}

	Super.ClickItem();
}


