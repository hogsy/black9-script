//=============================================================================
// B9InventoryBrowser
//
// 
//	The main inventory management object
// 
//=============================================================================


class B9InventoryBrowser extends Actor
	noexport
	native;


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var private float				fWeaponSwitchTimer;
var private float				fItemSwitchTimer;
var private float				fSkillSwitchTimer;

var bool						fWeaponSwitching;
var bool						fItemSwitching;
var bool						fSkillSwitching;
var private bool				fWeaponSwitched;
var private bool				fItemSwitched;
var private bool				fSkillSwitched;

var private transient B9InventoryItem fDisplayedWeapons[3];
var private transient B9InventoryItem fDisplayedItems[3];
var private transient B9InventoryItem fDisplayedSkills[3];
var private transient B9InventoryItem fSelectedWeapon;
var private transient B9InventoryItem fSelectedItem;
var private transient B9InventoryItem fSelectedSkill;

var private int					fSelectedColumn;
var private int					fLastClickDirection;
var private int					fSelectorLifeTimer;
var private bool				fSelectorActive;


// In the dll, these are actually tB9InventoryList pointers.
// But tB9InventoryList is a pure C++ class, not an Unreal 'native'
// class, so these dummies are here only so the size of the object comes up
// right when it gets deleted.
//
// What I really should do is make the List class an Unreal native class,
// but I'll do that later.
//
var private int	dummy1;
var private int	dummy2;
var private int	dummy3;
 



////////////////////////////////////////////////////
// C++ functions
//


// Display functions
//
native(3001) final function material	GetWeaponIcon( int position );
native(3002) final function material	GetItemIcon( int position );
native(3003) final function material	GetSkillIcon( int position );


native(3004) final function int			SetSelectedColumn( int column );
native(3005) final function int			GetSelectedColumn();

native(3006) final function int			GetLastClickDirection();
native(3007) final function bool		IsSelectorActive();


// Input functions
//
native(3008) final function				ScrollUp();
native(3009) final function				ScrollDown();
native(3010) final function				ScrollLeft();
native(3011) final function				ScrollRight();


// Interface for item switching stuff
//

native(3012) final function int			SetSelectedSkill( int keyVal );
native(3013) final function int			SetSelectedItem( int keyVal );
native(3014) final function int			SetSelectedWeapon( int keyVal );
native(3015) final function int			GetSelectedSkill();
native(3016) final function int			GetSelectedItem();
native(3017) final function int			GetSelectedWeapon();
native(3018) final function bool		NeedToSwitchSkill();
native(3019) final function bool		NeedToSwitchItem();
native(3020) final function bool		NeedToSwitchWeapon();


// Keep the timer a' tickin'
//
native(3021) final function				Update();


// List manipulation functions
//
native(3022) final function				RemoveSkill( int keyVal );
native(3023) final function				RemoveItem( int keyVal );
native(3024) final function				RemoveWeapon( int keyVal );
native(3025) final function				AddSkill( B9InventoryItem item );
native(3026) final function				AddItem( B9InventoryItem item );
native(3027) final function				AddWeapon( B9InventoryItem item );
native(3028) final function				ClearList();
native(3029) final function				ClearAll();
native(3030) final function				FillLists();


// To aid in the multiplayer war...
//
native(3031) final function	bool		QueryWeaponID( int id );
native(3032) final function	bool		QueryItemID( int id );
native(3033) final function	bool		QuerySkillID( int id );


////////////////////////////////////////////
//

defaultproperties
{
	bHidden=true
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false
}