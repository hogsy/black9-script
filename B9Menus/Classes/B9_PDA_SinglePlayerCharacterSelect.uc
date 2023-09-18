class B9_PDA_SinglePlayerCharacterSelect extends B9_MenuPDA_Menu;

var protected localized string 		fNameLabel;
var protected localized string 		fStrengthLabel;
var protected localized string 		fAgilityLabel;
var protected localized string 		fDexterityLabel;
var protected localized string 		fConstitutionLabel;
var protected localized string 		fAcceptLabel;
var protected localized string 		fNextLabel;
var protected localized string 		fE3DemoLabel;
var protected localized string 		fBackToMainLabel;
									
var protected displayItem			fName;
var protected displayItem			fStr;
var protected displayItem			fAgil;
var protected displayItem			fDex;
var protected displayItem			fCon;

var protected B9_PDABase			fPDA;

struct tPlayerInfo
{
	var string				fName;
	var int					fStr;
	var int					fAgil;
	var int					fDex;
	var int					fCon;
	var class<Pawn>			fPawnType;
	var class<Inventory>	fDefaultItemClasses[30];
};

var protected tPlayerInfo			fPlayerInfo;
var localized font fMSA20Font;

function SetupPlayerInfo();
function class<B9_MenuPDA_Menu> GetNextPlayerMenu();

function Setup( B9_PDABase pdaBase )
{	
	local displayItem newItem;
	local displayItem_3DPawn new3DPawnItem;
	local displayItem_AcceptSP newAcceptItem;
	local vector pawnLoc;

	Super.Setup( pdaBase );
	fPDA = pdaBase;
	fReturnMenu = class'B9_PDA_TopLevelMenu';
	SetupPlayerInfo();
	
	//E3 Demo Characters:
	newItem	= new(None)class'displayItem';
	newItem.fLabel			= fE3DemoLabel;
	newItem.fItemFont		= fMSA20Font;
	newItem.fTextColor.R	= 49;
	newItem.fTextColor.G	= 64;
	newItem.fTextColor.B	= 155;
	newItem.fCanAcceptFocus = false;
	newItem.fDrawNextItemTotheRight = false;
	AddDisplayItem( newItem );

	//Name:
	newItem					= new(None)class'displayItem';
	newItem.fLabel			= fNameLabel;
	newItem.fItemFont		= fMSA20Font;
	newItem.fCanAcceptFocus = false;
	newItem.fDrawNextItemTotheRight = true;
	AddDisplayItem( newItem );
	
	//Name value
	fName					= new(None)class'displayItem';
	fName.fLabel			= fPlayerInfo.fName;
	fName.fItemFont			= fMSA20Font;
	fName.fCanAcceptFocus	= false;
	fName.fDrawNextItemTotheRight = false;
	AddDisplayItem( fName );

	//3D Pawn
	new3DPawnItem				= new(None)class'displayItem_3DPawn';
	new3DPawnItem.fCanAcceptFocus = false;
	new3DPawnItem.fItemFont		= fMSA20Font;
	new3DPawnItem.fTextColor.R=185;
	new3DPawnItem.fTextColor.G=169;
	new3DPawnItem.fTextColor.B=93;
	pawnLoc.X = 523.0f;
	pawnLoc.Y = 644.0f;
	pawnLoc.Z = 145.0f;
	new3DPawnItem.SetupPawn( fPlayerInfo.fPawnType, pawnLoc, 1.0f, 34768 );  
	AddDisplayItem( new3DPawnItem );

	//Empty Space
	newItem				= new(None)class'displayItem';
	newItem.fLabel		= "                  ";
	newItem.fDrawNextItemTotheRight = false;
	newItem.fCanAcceptFocus = false;
	AddDisplayItem( newItem );

	//Strength: 
	newItem				= new(None)class'displayItem';
	newItem.fLabel		= fStrengthLabel;
	newItem.fItemFont=fMSA20Font;
	newItem.fCanAcceptFocus = false;
	newItem.fDrawNextItemTotheRight = true;
	AddDisplayItem( newItem );
	
	//Strength value
	fStr				= new(None)class'displayItem';
	fStr.fLabel			= string( fPlayerInfo.fStr );
	fStr.fItemFont		= fMSA20Font;
	fStr.fCanAcceptFocus = false;
	AddDisplayItem( fStr );

	//Agility
	newItem				= new(None)class'displayItem';
	newItem.fLabel		= fAgilityLabel;
	newItem.fItemFont	= fMSA20Font;
	newItem.fCanAcceptFocus = false;
	newItem.fDrawNextItemTotheRight = true;
	AddDisplayItem( newItem );
	
	//Agility value
	fAgil				= new(None)class'displayItem';
	fAgil.fLabel		= string( fPlayerInfo.fAgil );
	fAgil.fItemFont=fMSA20Font;
	fAgil.fCanAcceptFocus = false;
	AddDisplayItem( fAgil );

	//Dexterity
	newItem				= new(None)class'displayItem';
	newItem.fLabel		= fDexterityLabel;
	newItem.fItemFont	= fMSA20Font;
	newItem.fCanAcceptFocus = false;
	newItem.fDrawNextItemTotheRight = true;
	AddDisplayItem( newItem );
	
	//Dexterity value
	fDex				= new(None)class'displayItem';
	fDex.fLabel			= string( fPlayerInfo.fDex );
	fDex.fItemFont=fMSA20Font;
	fDex.fCanAcceptFocus = false;
	AddDisplayItem( fDex );

	//Constitution
	newItem				= new(None)class'displayItem';
	newItem.fLabel		= fConstitutionLabel;
	newItem.fItemFont=fMSA20Font;
	newItem.fCanAcceptFocus = false;
	newItem.fDrawNextItemTotheRight = true;
	AddDisplayItem( newItem );
	
	//Constitution value
	fCon				= new(None)class'displayItem';
	fCon.fLabel			= string( fPlayerInfo.fCon );
	fCon.fItemFont		= fMSA20Font;
	fCon.fCanAcceptFocus = false;
	AddDisplayItem( fCon );

	//Empty Space
	newItem				= new(None)class'displayItem';
	newItem.fLabel		= "                  ";
	newItem.fDrawNextItemTotheRight = false;
	newItem.fCanAcceptFocus = false;
	AddDisplayItem( newItem );
	
	//Accept
	newAcceptItem				= new(None)class'displayItem_AcceptSP';
	newAcceptItem.fLabel		= fAcceptLabel;
	newAcceptItem.fItemFont		= fMSA20Font;
	newAcceptItem.fTextColor.R	= 178;
	newAcceptItem.fTextColor.G	= 93;
	newAcceptItem.fTextColor.B	= 185;
	newAcceptItem.fCanAcceptFocus = true;
	newAcceptItem.fPlayerInfo = fPlayerInfo;
	AddDisplayItem( newAcceptItem );

	//Next
	newItem				= new(None)class'displayitem_GenericMenuItem';
	newItem.fLabel		= fNextLabel;
	newItem.fItemFont=fMSA20Font;
	newItem.fTextColor.R=97;
	newItem.fTextColor.G=93;
	newItem.fTextColor.B=185;
	newItem.fCanAcceptFocus = true;
	displayitem_GenericMenuItem( newItem ).fMenuClass = GetNextPlayerMenu();
	AddDisplayItem( newItem );

	//Back To Main
	/*newItem				= new(None)class'displayitem_GenericMenuItem';
	newItem.fLabel		= fBackToMainLabel;
	newItem.fItemFont=fMSA20Font;
	newItem.fTextColor.R=97;
	newItem.fTextColor.G=93;
	newItem.fTextColor.B=185;
	newItem.fCanAcceptFocus = true;
	displayitem_GenericMenuItem(newItem).fMenuClass = class'B9_PDA_TopLevelMenu';
	AddDisplayItem( newItem );
	*/
}

function bool handleKeyEvent(Interactions.EInputKey KeyIn,out Interactions.EInputAction Action, float Delta)
{
	if (fByeByeTicks == 0.0f)
	{
		return Super.handleKeyEvent( KeyIn , Action , Delta );
	}
	return false;

}


function Initialize()
{
	//Don't do anything requiring controllers here!
	// Initialized() must be implemented in any subclass, but it can do nothing.
	// It is called before MenuInit() and can't refer to RootInteraction,
	// RootController or ParentInteraction. You don't have to implement MenuInit(),
	// but you should call super.MenuInit() if you do.	
}
defaultproperties
{
	fNameLabel="Name: "
	fStrengthLabel="Strength: "
	fAgilityLabel="Agility: "
	fDexterityLabel="Dexterity: "
	fConstitutionLabel="Constitution: "
	fAcceptLabel="Accept"
	fNextLabel="Next"
	fE3DemoLabel="E3 Demo Characters"
	fBackToMainLabel="Return to main menu"
	fMSA20Font=Font'B9_Fonts.MicroscanA20'
	fReturnMenu=Class'B9BasicTypes.B9_MenuPDA_Menu'
}