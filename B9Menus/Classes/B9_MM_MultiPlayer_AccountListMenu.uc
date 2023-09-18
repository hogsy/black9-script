/////////////////////////////////////////////////////////////
// B9_MM_MultiPlayer_AccountListMenu
//
// Player must choose which user account they wish to use in Multiplayer.
// They can also create/delete these user accounts here.
// This is CURRENTLY a debug menu.

class B9_MM_MultiPlayer_AccountListMenu extends B9_MM_SimpleListMenu;

var localized string fCreateUserLabel;
var localized string fDeleteUserLabel;
var int fCreateItem;
var int fDeleteItem;


var B9MP_Client fClient;


// Initialized() must be implemented in any subclass, but it can do nothing.
// It is called before MenuInit() and can't refer to RootInteraction,
// RootController or ParentController. You don't have to implement MenuInit(),
// but you should call super.MenuInit().
function Initialized()
{
	fHasGoBack = true;
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	local class<B9MP_ClientManager> fClientManagerClass;
	local class<B9MP_Client> fClientClass;
	local String onlinePkgNameSuffix;
	
	if ( IsPlatformXBox() )
	{
		onlinePkgNameSuffix = "XBox";
	}
	else
	{
		onlinePkgNameSuffix = "GameSpy";
	}
	
	Super.MenuInit( interaction, controller, parent );

	if ( fClientManager == None )
	{
		ForEach controller.AllActors( class'B9MP_ClientManager', fClientManager )
		{
			break;
		}
		
		if ( fClientManager == None )
		{
			fClientManagerClass = class<B9MP_ClientManager>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_ClientManager_" $ onlinePkgNameSuffix, class'Class'));
			if(fClientManagerClass == None)
			{
				Log( "Failed to create fClientManagerClass" );
			}
			fClientManager = controller.Spawn( fClientManagerClass );			
			if(fClientManager == None)
			{
				Log( "Failed to create fClientManager" );
			}
		}
	}

	if ( fClient == None )
	{
		ForEach controller.AllActors( class'B9MP_Client', fClient )
		{
			break;
		}
		
		if ( fClient == None )
		{
			fClientClass = class<B9MP_Client>(DynamicLoadObject("B9MP_" $ onlinePkgNameSuffix $ ".B9MP_Client_" $ onlinePkgNameSuffix, class'Class'));
			if(fClientClass == None)
			{
				Log( "Failed to create fClientClass" );
			}
			fClient = controller.Spawn( fClientClass );
			if( fClient == None )
			{
			
			}
		}
	}

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
	local B9MP_ClientDescription ClientDesc;
	local int nUserCount;
	local LinkedListElement element;
	
	nUserCount = fClientManager.fClients.GetCount();

	x = 43;
	y = 281;
	yOffset = 40;
	yImageOffset = 60;

	fItemArray.Length = 2 + nUserCount;
	fCreateItem = nUserCount;
	fDeleteItem = nUserCount + 1;

	element = fClientManager.fClients.GetTop();

	i = 0;
	while( element != None )
	{
		ClientDesc = B9MP_ClientDescription(element.fObject);
		
		fItemArray[ i ].X = x;
		fItemArray[ i ].Y = y;
		fItemArray[ i ].Label = ClientDesc.fInfo.fName;

		y += yOffset;
		element = element.fNext;
		i++;
	}

	fItemArray[ i ].X = x;
	fItemArray[ i ].Y = y;
	fItemArray[ i ].Label = fCreateUserLabel;

	y += yOffset;
	i++;

	fItemArray[ i ].X = x;
	fItemArray[ i ].Y = y;
	fItemArray[ i ].Label = fDeleteUserLabel;

	y += yImageOffset;


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
		// Flip the choices (so fixed choices are consistently 0 or 1 for external menu)
		switch ( fSelItem )
		{
		case fCreateItem:
		log("create new user");
			return;

		case fDeleteItem:
			fSelItem = 1;
			fClient.Delete();
			return;

		default:
			if ( DoLogin( fSelItem ) )
			{
				Log( "KMY: Failed login - " $ fClient.fErrorMessage );
				return;
			}
			else
			{
				fSelItem += 2;
			}
			break;
		}
	}

	Super.ClickItem();
}

function bool DoLogin(int fSelItem)
{
	local B9MP_ClientDescription ClientDesc;

	ClientDesc = B9MP_ClientDescription( fClientManager.fClients.GetElement( fSelItem ) );

	if ( ClientDesc != None )
	{
		fClient.fClientDescription.fInfo.fName	   = ClientDesc.fInfo.fName;
		fClient.fClientDescription.fInfo.fNickName = ClientDesc.fInfo.fNickName;
		fClient.fClientDescription.fInfo.fPassword = ClientDesc.fInfo.fPassword;

		if ( fClient.Login() == kSuccess )
			return false;
	}

	return true;
}


defaultproperties
{
	fCreateUserLabel="Create User Account"
	fDeleteUserLabel="Delete User Account"
}