class  displayitem_TopLevelMenu extends displayItem;

var class<B9_MenuPDA_Menu> fNextMenuName;
var int	fItemToChange;
var private class<Pawn> fCharClass;
var material fBlack9TitleLeft;
var material fBlack9TitleRight;
//
var class<Inventory> DefaultItemClasses[10];
//
function bool handleKeyEvent( Interactions.EInputKey KeyIn, out Interactions.EInputAction Action, float Delta)
{
// Default handler handles nothing overload this to add functionality
	return false;
}
function ClickItem(optional B9_MenuPDA_Menu menu)
{
	Super.ClickItem( menu );
}
// This is the function that is called when the displayitem is selected only if fbStartByeByeTImerOnClick is true
function ActOnClick(out B9_PDABase PDA,optional class<B9_MenuPDA_Menu> returnMenuClass)
{
	if( fItemToChange == 5 )
	{
		PDA.RootController.Player.Actor.ConsoleCommand("exit");
	}
	else
	{
		PDA.AddMenu( fNextMenuName, returnMenuClass );
	}



	return;
}
defaultproperties
{
	fBlack9TitleLeft=Texture'B9Menu_tex_std.titles.title_left'
	fBlack9TitleRight=Texture'B9Menu_tex_std.titles.title_right'
	DefaultItemClasses[0]=Class'B9NanoSkills.skill_Hacking'
	DefaultItemClasses[1]=Class'B9Weapons.HandToHand'
	DefaultItemClasses[2]=Class'B9Gear.PDA'
	DefaultItemClasses[3]=Class'B9NanoSkills.skill_Jumping'
	DefaultItemClasses[4]=Class'B9NanoSkills.skill_meleeCombat'
	DefaultItemClasses[5]=Class'B9NanoSkills.skill_FireArmsTargeting'
	DefaultItemClasses[6]=Class'B9NanoSkills.skill_HeavyWeaponsTargeting'
	DefaultItemClasses[7]=Class'B9NanoSkills.skill_urbanTracking'
}