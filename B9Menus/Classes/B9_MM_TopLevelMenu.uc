/////////////////////////////////////////////////////////////
// B9_MM_TopLevelMenu
//

class B9_MM_TopLevelMenu extends B9_MM_SimpleListMenu;

/*
var private texture fJumpToSaveTextureUnselLt;
var private texture fJumpToSaveTextureUnselRt;
var private texture fJumpToSaveTextureSelLt;
var private texture fJumpToSaveTextureSelRt;
var private texture fJumpToSaveTextureClickLt;
var private texture fJumpToSaveTextureClickRt;

var private texture fMultiPlayerTextureUnselLt;
var private texture fMultiPlayerTextureUnselRt;
var private texture fMultiPlayerTextureSelLt;
var private texture fMultiPlayerTextureSelRt;
var private texture fMultiPlayerTextureClickLt;
var private texture fMultiPlayerTextureClickRt;

var private texture fSinglePlayerTextureUnselLt;
var private texture fSinglePlayerTextureUnselRt;
var private texture fSinglePlayerTextureSelLt;
var private texture fSinglePlayerTextureSelRt;
var private texture fSinglePlayerTextureClickLt;
var private texture fSinglePlayerTextureClickRt;

var private texture fOptionsTextureUnselLt;
var private texture fOptionsTextureUnselRt;
var private texture fOptionsTextureSelLt;
var private texture fOptionsTextureSelRt;
var private texture fOptionsTextureClickLt;
var private texture fOptionsTextureClickRt;
*/

var private int fSinglePlayerX;
var private int fSinglePlayerY;
var private int fMultiPlayerX;
var private int fMultiPlayerY;
var private int fOptionsX;
var private int fOptionsY;
var private int fJumpToSaveConsoleX;
var private int fJumpToSaveConsoleY;
var private int fJumpToSavePCX;
var private int fJumpToSavePCY;
var private int fQuitX;
var private int fQuitY;

var localized string fSinglePlayerLabel;
var localized string fMultiPlayerLabel;
var localized string fOptionsLabel;
var localized string fJumpToSaveLabel;
var localized string fQuitLabel;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Initialized()
{
	local SimpleItemInfo info;
	local SimpleImageInfo img;

	log(self@"I'm alive");

	if (Platform() == "PC")
	{
		fItemArray.Length = 5;

		info.X = fSinglePlayerX;
		info.Y = fSinglePlayerY;
		info.Label = fSinglePlayerLabel;
		fItemArray[0] = info;

		info.X = fMultiPlayerX;
		info.Y = fMultiPlayerY;
		info.Label = fMultiPlayerLabel;
		fItemArray[1] = info;

		info.X = fOptionsX;
		info.Y = fOptionsY;
		info.Label = fOptionsLabel;
		fItemArray[2] = info;

		info.X = fJumpToSavePCX;
		info.Y = fJumpToSavePCY;
		info.Label = fJumpToSaveLabel;
		fItemArray[3] = info;

		info.X = fQuitX;
		info.Y = fQuitY;
		info.Label = fQuitLabel;
		fItemArray[4] = info;
	}
	else
	{
		fItemArray.Length = 4;

		info.X = fSinglePlayerX;
		info.Y = fSinglePlayerY;
		info.Label = fSinglePlayerLabel;
		//info.UnselLt = fSinglePlayerTextureUnselLt;
		//info.UnselRt = fSinglePlayerTextureUnselRt;
		//info.SelLt = fSinglePlayerTextureSelLt;
		//info.SelRt = fSinglePlayerTextureSelRt;
		//info.ClickLt = fSinglePlayerTextureClickLt;
		//info.ClickRt = fSinglePlayerTextureClickRt;
		fItemArray[0] = info;

		info.X = fMultiPlayerX;
		info.Y = fMultiPlayerY;
		info.Label = fMultiPlayerLabel;
		//info.UnselLt = fMultiPlayerTextureUnselLt;
		//info.UnselRt = fMultiPlayerTextureUnselRt;
		//info.SelLt = fMultiPlayerTextureSelLt;
		//info.SelRt = fMultiPlayerTextureSelRt;
		//info.ClickLt = fMultiPlayerTextureClickLt;
		//info.ClickRt = fMultiPlayerTextureClickRt;
		fItemArray[1] = info;

		info.X = fOptionsX;
		info.Y = fOptionsY;
		info.Label = fOptionsLabel;
		//info.UnselLt = fOptionsTextureUnselLt;
		//info.UnselRt = fOptionsTextureUnselRt;
		//info.SelLt = fOptionsTextureSelLt;
		//info.SelRt = fOptionsTextureSelRt;
		//info.ClickLt = fOptionsTextureClickLt;
		//info.ClickRt = fOptionsTextureClickRt;
		fItemArray[2] = info;

		info.X = fJumpToSaveConsoleX;
		info.Y = fJumpToSaveConsoleY;
		info.Label = fJumpToSaveLabel;
		//info.UnselLt = fJumpToSaveTextureUnselLt;
		//info.UnselRt = fJumpToSaveTextureUnselRt;
		//info.SelLt = fJumpToSaveTextureSelLt;
		//info.SelRt = fJumpToSaveTextureSelRt;
		//info.ClickLt = fJumpToSaveTextureClickLt;
		//info.ClickRt = fJumpToSaveTextureClickRt;
		fItemArray[3] = info;
	}

	fImageArray.Length = 1;

	img.X = 192;
	img.Y = 416;
	img.Image = texture'B9MenuHelp_Textures.choice_select';

	fImageArray[0] = img;

	Super.Initialized();
}

defaultproperties
{
	fSinglePlayerX=64
	fSinglePlayerY=203
	fMultiPlayerX=64
	fMultiPlayerY=243
	fOptionsX=64
	fOptionsY=283
	fJumpToSaveConsoleX=64
	fJumpToSaveConsoleY=354
	fJumpToSavePCX=64
	fJumpToSavePCY=323
	fQuitX=64
	fQuitY=363
	fSinglePlayerLabel="SINGLE PLAYER"
	fMultiPlayerLabel="MULTIPLAYER"
	fOptionsLabel="OPTIONS"
	fJumpToSaveLabel="JUMP TO LAST SAVE"
	fQuitLabel="QUIT"
}