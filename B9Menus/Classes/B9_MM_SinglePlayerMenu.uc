/////////////////////////////////////////////////////////////
// B9_MM_SinglePlayerMenu
//

class B9_MM_SinglePlayerMenu extends B9_MM_SimpleListMenu;

var localized string fNewCareerLabel;
var localized string fLoadCareerLabel;

// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Initialized()
{
	local SimpleItemInfo info;
	local SimpleImageInfo img;

	log(self@"I'm alive");

	fItemArray.Length = 2;

	info.X = 43;
	info.Y = 281;
	info.Label = fNewCareerLabel;
	//info.UnselLt = texture'B9Menu_Textures.new_career_left';
	//info.UnselRt = texture'B9Menu_Textures.new_career_right';
	//info.SelLt = texture'B9Menu_Textures.new_career_left_hilight';
	//info.SelRt = texture'B9Menu_Textures.new_career_right_hilight';
	//info.ClickLt = texture'B9Menu_Textures.new_career_left_click';
	//info.ClickRt = texture'B9Menu_Textures.new_career_right_click';
	fItemArray[0] = info;

	info.X = 43;
	info.Y = 321;
	info.Label=fLoadCareerLabel;
	//info.UnselLt = texture'B9Menu_Textures.load_career_left';
	//info.UnselRt = texture'B9Menu_Textures.load_career_right';
	//info.SelLt = texture'B9Menu_Textures.load_career_left_hilight';
	//info.SelRt = texture'B9Menu_Textures.load_career_right_hilight';
	//info.ClickLt = texture'B9Menu_Textures.load_career_left_click';
	//info.ClickRt = texture'B9Menu_Textures.load_career_right_click';
	fItemArray[1] = info;

	fImageArray.Length = 4;

	img.X = 64;
	img.Y = 203;
	img.Image = texture'B9Menu_tex_std.sp_title_left';
	fImageArray[0] = img;

	img.X = 320;
	img.Y = 203;
	img.Image = texture'B9Menu_tex_std.sp_title_right';
	fImageArray[1] = img;

	img.X = 64;
	img.Y = 416;
	img.Image = texture'B9MenuHelp_Textures.choice_select';
	fImageArray[2] = img;

	img.X = 320;
	img.Y = 416;
	img.Image = texture'B9MenuHelp_Textures.choice_back';
	fImageArray[3] = img;

	fHasGoBack = true;

	Super.Initialized();
}

defaultproperties
{
	fNewCareerLabel="NEW CAREER"
	fLoadCareerLabel="LOAD CAREER"
}