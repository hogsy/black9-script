/////////////////////////////////////////////////////////////
// B9_PDABase
//

class B9_PDABase extends B9_MenuInteraction;

struct tPoint2D
{
	var int fX;
	var int fY;
};

struct tMenuPiece
{
	var material fTexture;
	var tPoint2D fPos;
	var tPoint2D fSize;
	var tPoint2D fUVSize;
};

struct tMenuText
{
	var String fText;
	var tPoint2D fPos;
};

var array<B9_MenuPDA_Menu>	fMenus;
var B9_MenuPDA_Menu			fPrevMenu;
var array<tMenuPiece>		fMenuPieces;
var array<tMenuText>		fMenuTexts;
var int						fButtonOneIndex;
var int						fButtonTwoIndex;
var int						fButtonThreeIndex;
var int						fButtonFourIndex;
var int						fButtonOneTextIndex;
var int						fButtonTwoTextIndex;
var int						fButtonThreeTextIndex;
var int						fButtonFourTextIndex;
var int						fDPadIndex;

var int						fSelectedMenu;
var bool					fHidden;
var bool					fHideMenu;
var int						fBeginPoint_X;
var int						fBeginPoint_Y;
var int						fEndPoint_X;
var int						fEndPoint_Y;

var int						fFrameArt_BeginPoint_X;
var int						fFrameArt_BeginPoint_Y;
var int						fFrameArt_EndPoint_X;
var int						fFrameArt_EndPoint_Y;

var bool					fHasGoBack;

var localized string 		fButton1Text;
var localized string 		fButton2Text;
var localized string 		fButton3Text;
var localized string 		fButton4Text;

var localized string 		fButtonOneLabel;
var localized string 		fButtonTwoLabel;
var localized string 		fButtonThreeLabel;
var localized string 		fButtonFourLabel;

var material				fPDAMenuBacking;

var material				fPDAUpperLeftCorner;
var material				fPDATopSegment;
var material				fPDATop; 
var material				fPDAUpperRightCorner; // Uses left corner fliped horiz
var material				fPDALeftSegment;
var material				fPDARightSegment;
var material				fPDALowerLeftCorner;
var material				fPDALowerSegment1;
var material				fPDALowerSegment2;
var material				fPDALowerRightCorner; // Uses left corner fliped horiz	

var material				fPDA_Button1Tex;
var material				fPDA_AButton_Grey;
var material				fPDA_AButton_Active;
var material				fPDA_AButton_Ready;

var material				fPDA_Button2Tex;
var material				fPDA_BButton_Grey;
var material				fPDA_BButton_Active;
var material				fPDA_BButton_Ready;

var material				fPDA_Button3Tex;
var material				fPDA_XButton_Grey;			
var material				fPDA_XButton_Active;			
var material				fPDA_XButton_Ready;			

var material				fPDA_Button4Tex;
var material				fPDA_YButton_Grey;			
var material				fPDA_YButton_Active;			
var material				fPDA_YButton_Ready;

var material				fPDA_AButton_Grey_PC;
var material				fPDA_AButton_Active_PC;
var material				fPDA_AButton_Ready_PC;

var material				fPDA_BButton_Grey_PC;
var material				fPDA_BButton_Active_PC;
var material				fPDA_BButton_Ready_PC;

var material				fPDA_XButton_Grey_PC;			
var material				fPDA_XButton_Active_PC;			
var material				fPDA_XButton_Ready_PC;			

var material				fPDA_YButton_Grey_PC;			
var material				fPDA_YButton_Active_PC;			
var material				fPDA_YButton_Ready_PC;


var material				fPDA_DPadTex;
var material				fPDA_DirReadyTex;
var material				fPDA_DirDownTex;
var material				fPDA_DirUpTex;
var material				fPDA_DirLeftTex;
var material				fPDA_DirRightTex;

var int						fPDAMode;
var bool					fInitializePDASize;


var B9_MenuInteraction		fFromOldMenu;
var name					fBackToLastState;
var class<B9_MenuInteraction>	fOldChildInterationClass;

var font fButtonLabelFont;

function tPoint2D _tPoint2D( int x, int y )
{
	local tPoint2D point;
	point.fX = x;
	point.fY = y;
	
	return point;
}

function tMenuPiece _tMenuPiece( material texture, tPoint2D pos, tPoint2D size )
{
	return _tMenuPieceUV( texture, pos, size, size );
}

function tMenuPiece _tMenuPieceUV( material texture, tPoint2D pos, tPoint2D size, tPoint2D uvSize )
{
	local tMenuPiece menuPiece;
	
	menuPiece.fTexture = texture;
	menuPiece.fPos = pos;
	menuPiece.fSize = size;
	menuPiece.fUVSize = uvSize;
	
	return menuPiece;
}

function tMenuText _tMenuText( String text, tPoint2D pos )
{
	local tMenuText menuText;
	
	menuText.fText = text;
	menuText.fPos = pos;
	
	return menuText;
}

function Initialized()
{
	local int menuPieceIndex;
	menuPieceIndex = 0;
	
	log("PDA Initialized");
	fSelectedMenu = 0;
	fBeginPoint_X = 0;
	fBeginPoint_Y = 0;
	fEndPoint_X   = 500;
	fEndPoint_Y   = 500;
	
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDAUpperLeftCorner,	_tPoint2D( 0,0 ),		_tPoint2D( 64,128 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPieceUV( fPDAUpperRightCorner,_tPoint2D( 576,0 ),		_tPoint2D( 64,128 ), _tPoint2D( -64,128 ) );
	
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATop,				_tPoint2D( 256,0 ),		_tPoint2D( 128,64 ) );
/*
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 64,0 ),		_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 96,0 ),		_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 128,0 ),		_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 160,0 ),		_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 192,0 ),		_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 224,0 ),		_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 384,0 ),		_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 416,0 ),		_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 448,0 ),		_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 480,0 ),		_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 512,0 ),		_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDATopSegment,		_tPoint2D( 544,0 ),		_tPoint2D( 32,64 ) );
*/

/*
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDALeftSegment,		_tPoint2D( 0,128 ), 	_tPoint2D( 64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDALeftSegment,		_tPoint2D( 0,160 ),		_tPoint2D( 64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDALeftSegment,		_tPoint2D( 0,192 ),		_tPoint2D( 64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDALeftSegment,		_tPoint2D( 0,224 ),		_tPoint2D( 64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDALeftSegment,		_tPoint2D( 0,256 ),		_tPoint2D( 64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDALeftSegment,		_tPoint2D( 0,288 ),		_tPoint2D( 64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDALeftSegment,		_tPoint2D( 0,320 ),		_tPoint2D( 64,32 ) );
*/

	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDALowerLeftCorner,	_tPoint2D( 0,352 ),		_tPoint2D( 64,128 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPieceUV( fPDALowerRightCorner,_tPoint2D( 576,352 ),	_tPoint2D( 64,128 ), _tPoint2D( -64,128 ) );
	
/*
	fMenuPieces[menuPieceIndex++] = _tMenuPiece( fPDALowerSegment1,		_tPoint2D( 64,416 ),	_tPoint2D( 32,64 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPieceUV( fPDALowerSegment2,		_tPoint2D( 544,416 ),	_tPoint2D( 32,64 ), _tPoint2D( -32,64 ) );
*/

/*
	fMenuPieces[menuPieceIndex++] = _tMenuPieceUV( fPDARightSegment,		_tPoint2D( 576,128 ),	_tPoint2D( 64,32 ), _tPoint2D( -64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPieceUV( fPDARightSegment,		_tPoint2D( 576,160 ),	_tPoint2D( 64,32 ), _tPoint2D( -64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPieceUV( fPDARightSegment,		_tPoint2D( 576,192 ),	_tPoint2D( 64,32 ), _tPoint2D( -64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPieceUV( fPDARightSegment,		_tPoint2D( 576,224 ),	_tPoint2D( 64,32 ), _tPoint2D( -64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPieceUV( fPDARightSegment,		_tPoint2D( 576,256 ),	_tPoint2D( 64,32 ), _tPoint2D( -64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPieceUV( fPDARightSegment,		_tPoint2D( 576,288 ),	_tPoint2D( 64,32 ), _tPoint2D( -64,32 ) );
	fMenuPieces[menuPieceIndex++] = _tMenuPieceUV( fPDARightSegment,		_tPoint2D( 576,320 ),	_tPoint2D( 64,32 ), _tPoint2D( -64,32 ) );
*/

	fButtonOneIndex = menuPieceIndex++;
	fMenuPieces[fButtonOneIndex] =  _tMenuPiece( fPDA_AButton_Grey,		_tPoint2D( 352,416 ),	_tPoint2D( 128,64 ) );
	
	fButtonTwoIndex = menuPieceIndex++;
	fMenuPieces[fButtonTwoIndex] =  _tMenuPiece( fPDA_BButton_Grey,		_tPoint2D( 480,416 ),	_tPoint2D( 64,64 ) );
	
	fButtonThreeIndex = menuPieceIndex++;
	fMenuPieces[fButtonThreeIndex] =  _tMenuPiece( fPDA_XButton_Grey,		_tPoint2D( 96,416 ),	_tPoint2D( 64,64 ) );
	
	fButtonFourIndex = menuPieceIndex++;
	fMenuPieces[fButtonFourIndex] =  _tMenuPiece( fPDA_YButton_Grey,		_tPoint2D( 160,416 ),	_tPoint2D( 128,64 ) );
	
	fDPadIndex = menuPieceIndex++;
	fMenuPieces[fDPadIndex] =  _tMenuPiece( fPDA_DirReadyTex,		_tPoint2D( 288,352 ),	_tPoint2D( 64,128 ) );
	
	
	// Text setup
	menuPieceIndex = 0;
	
	fButtonOneTextIndex = menuPieceIndex++;
	fMenuTexts[fButtonOneTextIndex] = _tMenuText( "", _tPoint2D( 353,447 ) );

	fButtonTwoTextIndex = menuPieceIndex++;
	fMenuTexts[fButtonTwoTextIndex] = _tMenuText( "", _tPoint2D( 481,447 ) );
	
	fButtonThreeTextIndex = menuPieceIndex++;
	fMenuTexts[fButtonThreeTextIndex] = _tMenuText( "", _tPoint2D( 56,447 ) );
	
	fButtonFourTextIndex = menuPieceIndex++;
	fMenuTexts[fButtonFourTextIndex] = _tMenuText( "", _tPoint2D( 173,447 ) );
}

// Since we can not delete new'ed objects in unreal we cache them, and when we want to use a menu, we check the cache first.

function AddMenu( class<B9_MenuPDA_Menu> newMenu , optional class<B9_MenuPDA_Menu> returnMenu )
{
	local int i;

	if( newMenu == None )
	{
		log("Hidding Menu");
		SetSelectedMenu( -1 );
		fHidden = true;
		fHideMenu = true;
		RemovePDAFromContollerList();
		if( RootController.Level.Pauser != None )
		{
			// Un Pause the game if it was paused
			RootController.Pause();
		}
			
		if( fFromOldMenu != None )
		{
			fFromOldMenu.MakeChildInteraction(fOldChildInterationClass);
			fFromOldMenu.GotoState(fBackToLastState);
		}
		return;
	}else
	{
		fHidden = false;
		fHideMenu = false;
	}

	if (fSelectedMenu < fMenus.length)
	{
		fPrevMenu = fMenus[fSelectedMenu];
	}

	for( i = 0; i < fMenus.length ; i++ )
	{
		// Check to see if we already have this
		if( fMenus[i].IsA( newMenu.Name ) == true )
		{
			if( returnMenu != None )
			{
				fMenus[i].fReturnMenu = returnMenu;
				fMenus[i].FullReset();
			}else
			{
				fMenus[i].PartialReset();
			}
			
			log("Found Menu");
			SetSelectedMenu( i );
			return;
		}
	}
	// if we don't have it, put in in the front of the line
	fMenus.Insert(0,1);
	log("Adding new Menu");
	fMenus[0]				= new (None) newMenu;
	if( returnMenu != None )
	{
		fMenus[0].fReturnMenu	= returnMenu;
	}
	fMenus[0].fPDABase = self;
	fMenus[0].Setup( self );
	fMenus[0].FullReset();
	SetSelectedMenu( 0 );
}

function SetSelectedMenu( Int index )
{
	if( fSelectedMenu > -1 )
	{
		fMenus[ fSelectedMenu ].LostFocus();
	}
	
	fSelectedMenu = index;
	
	if( fSelectedMenu > -1 )
	{
		fMenus[ fSelectedMenu ].GainFocus();
	}
}

function Tick(float Delta)
{
	if( fSelectedMenu > -1 )
	{
		fMenus[fSelectedMenu].UpdateMenu( Delta );
	}else
	{
		log("Falling out of Tick");
	}

}

// Copy and Paste */
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local bool MenuResult;
	if ( Action == IST_Axis && Key == IK_MouseX )
	{
		MouseX = (ViewportOwner.WindowsMouseX / GUIScale) - OriginX;
	}

	if ( Action == IST_Axis && Key == IK_MouseY )
	{
		MouseY = ViewportOwner.WindowsMouseY / GUIScale - OriginY;
	}

	if( fSelectedMenu > -1 )
	{
		MenuResult = fMenus[fSelectedMenu].handleKeyEvent( Key, Action, Delta );
//		log("MenuResult is "$MenuResult);
//		return MenuResult;
	}else
	{
		log("Falling out of KeyEvent");
//		return false;
	}
	return true;
}

function PostRender( canvas Canvas )
{
	local color	oldDrawColor;


	if ( fHidden == false )
	{
		oldDrawColor	= Canvas.DrawColor;

		if (fInitializePDASize == false )
		{
			fFrameArt_BeginPoint_X	= (Canvas.ClipX - 640) /2;
			fFrameArt_BeginPoint_Y	= (Canvas.ClipY - 480) /2;
			fFrameArt_EndPoint_X	= fFrameArt_BeginPoint_X + 640;
			fFrameArt_EndPoint_Y	= fFrameArt_BeginPoint_Y + 480;
			
			fBeginPoint_X			= fFrameArt_BeginPoint_X + 50;
			fBeginPoint_Y			= fFrameArt_BeginPoint_Y + 55;
			fEndPoint_X				= fBeginPoint_X + 620;
			fEndPoint_Y				= fBeginPoint_Y + 440;

			if( IsPlatformPC() )
			{
				fPDA_AButton_Grey			= 	fPDA_AButton_Grey_PC;
				fPDA_AButton_Active			= 	fPDA_AButton_Active_PC;
				fPDA_AButton_Ready			= 	fPDA_AButton_Ready_PC;	
											  	
				fPDA_BButton_Grey			= 	fPDA_BButton_Grey_PC;	
				fPDA_BButton_Active			= 	fPDA_BButton_Active_PC;	
				fPDA_BButton_Ready			= 	fPDA_BButton_Ready_PC;	
											  	
				fPDA_XButton_Grey			= 	fPDA_XButton_Grey_PC;	
				fPDA_XButton_Active			= 	fPDA_XButton_Active_PC;	
				fPDA_XButton_Ready			= 	fPDA_XButton_Ready_PC;	
											  	
				fPDA_YButton_Grey			= 	fPDA_YButton_Grey_PC;	
				fPDA_YButton_Active			= 	fPDA_YButton_Active_PC;	
				fPDA_YButton_Ready			= 	fPDA_YButton_Ready_PC;	
			}
			/*
			fBeginPoint_X			= 64;
			fBeginPoint_Y			= 64;
			fEndPoint_X				= Canvas.ClipX - 64;
			fEndPoint_Y				= Canvas.ClipY - 64;
			*/
		}

		DrawPDABackground( Canvas );

		Canvas.SetDrawColor( 255, 255, 255, 255 );
		// Tell the menu to Draw ?
		if ( fHideMenu == false && fSelectedMenu > -1 )
		{
			fMenus[fSelectedMenu].PostRender( Canvas );
		}
		else
		{
//			log("Falling out of Post Render");
		}

		DrawPDAFrame( Canvas );

		Canvas.DrawColor	= oldDrawColor;
	}
}

function DrawPDABackground( canvas Canvas )
{
	local byte	oldStyle;
	local color oldDrawColor;


	oldStyle		= Canvas.Style;
	oldDrawColor	= Canvas.DrawColor;

	Canvas.Style	= RootController.ERenderStyle.STY_Normal;
	Canvas.SetDrawColor( 255, 255, 255, 255 );

	// background
	Canvas.SetPos( Canvas.OrgX, Canvas.OrgY );
	Canvas.DrawTileClipped( fPDAMenuBacking, Canvas.ClipX - Canvas.OrgX, Canvas.ClipY - Canvas.OrgY, 0, 0,  128, 16);

	Canvas.Style		= oldStyle;
	Canvas.DrawColor	= oldDrawColor;
}

function DrawPDAFrame( canvas Canvas )
{
	local byte	oldStyle;
	local color oldDrawColor;
	local Font	oldFont;
	local float	DPadX;
	local float	button1X;
	local float	button2X;
	local float	button3X;
	local float	button4X;


	oldStyle		= Canvas.Style;
	oldDrawColor	= Canvas.DrawColor;
	oldFont			= Canvas.Font;

	Canvas.Style	= RootController.ERenderStyle.STY_Normal;
	Canvas.SetDrawColor( 255, 255, 255, 255 );

	// top left corner
	Canvas.SetPos( Canvas.OrgX, Canvas.OrgY );
	Canvas.DrawTile( fPDAUpperLeftCorner, 64, 128, 0, 0, 64, 128 );
	// top tile
	Canvas.SetPos( Canvas.OrgX + 64, Canvas.OrgY );
	Canvas.DrawTile( fPDATopSegment, Canvas.ClipX - Canvas.OrgX - 128, 64, 0, 0, 32, 64 );
	// top right corner
	Canvas.SetPos( Canvas.ClipX - 64, Canvas.OrgY );
	Canvas.DrawTile( fPDAUpperRightCorner, 64, 128, 0, 0, -64, 128 );
	// top logo
	Canvas.SetPos( ( Canvas.ClipX - Canvas.OrgX - 128 ) / 2, Canvas.OrgY );
	Canvas.DrawTile( fPDATop, 128, 64, 0, 0, 128, 64 );

	// middle left tile
	Canvas.SetPos( Canvas.OrgX, Canvas.OrgY + 128 );
	Canvas.DrawTile( fPDALeftSegment, 64, Canvas.ClipY - Canvas.OrgY - 256, 0, 0, 64, 32 );
	// middle right tile
	Canvas.SetPos( Canvas.ClipX - 64, Canvas.OrgY + 128 );
	Canvas.DrawTile( fPDALeftSegment, 64, Canvas.ClipY - Canvas.OrgY - 256, 0, 0, -64, 32 );

	// bottom left corner
	Canvas.SetPos( Canvas.OrgX, Canvas.ClipY - 128 );
	Canvas.DrawTile( fPDALowerLeftCorner, 64, 128, 0, 0, 64, 128 );
	// bottom tile
	Canvas.SetPos( Canvas.OrgX + 64, Canvas.ClipY - 64 );
	Canvas.DrawTile( fPDALowerSegment1, Canvas.ClipX - Canvas.OrgX - 128, 64, 0, 0, 32, 64 );
	// bottom right corner
	Canvas.SetPos( Canvas.ClipX - 64, Canvas.ClipY - 128 );
	Canvas.DrawTile( fPDALowerRightCorner, 64, 128, 0, 0, -64, 128 );

	UpdateButtonState( Canvas );

	// DPad
	DPadX	= ( Canvas.ClipX - Canvas.OrgX - 64 ) / 2;
	Canvas.SetPos( DPadX, Canvas.ClipY - 128 );
	Canvas.DrawTile( fPDA_DPadTex, 64, 128, 0, 0, 64, 128 );
	// button 1/A/cross
	button1X	= DPadX + 64;
	Canvas.SetPos( button1X, Canvas.ClipY - 64 );
	Canvas.DrawTile( fPDA_Button1Tex, 128, 64, 0, 0, 128, 64 );
	// button 2/B/circle
	button2X	= DPadX + 64 + 128;
	Canvas.SetPos( button2X, Canvas.ClipY - 64 );
	Canvas.DrawTile( fPDA_Button2Tex, 64, 64, 0, 0, 64, 64 );
	// button 3/X/square
	button3X	= DPadX - 128 - 64;
	Canvas.SetPos( button3X, Canvas.ClipY - 64 );
	Canvas.DrawTile( fPDA_Button3Tex, 64, 64, 0, 0, 64, 64 );
	// button 4/Y/triangle
	button4X	= DPadX - 128;
	Canvas.SetPos( button4X, Canvas.ClipY - 64 );
	Canvas.DrawTile( fPDA_Button4Tex, 128, 64, 0, 0, 128, 64 );

	// Draw text
	Canvas.SetDrawColor( 200, 200, 255 );
	Canvas.Font	= fButtonLabelFont;
	// button 1/A/cross
	Canvas.SetPos( button1X + 1, Canvas.ClipY - 64 + 31 );
	Canvas.DrawText( fButton1Text, false );
	// button 2/B/circle
	Canvas.SetPos( button2X + 1, Canvas.ClipY - 64 + 31 );
	Canvas.DrawText( fButton2Text, false );
	// button 3/X/square
	Canvas.SetPos( button3X - 40, Canvas.ClipY - 64 + 31 );
	Canvas.DrawText( fButton3Text, false );
	// button 4/Y/triangle
	Canvas.SetPos( button4X + 13, Canvas.ClipY - 64 + 31 );
	Canvas.DrawText( fButton4Text, false );

	Canvas.Style		= oldStyle;
	Canvas.DrawColor	= oldDrawColor;
	Canvas.Font			= oldFont;
}

function UpdateButtonState( canvas Canvas )
{
	local int XButton;
	local int YButton;
	local int AButton;
	local int BButton;

	// Querry Button States
	fMenus[ fSelectedMenu ].QuerryButtonOptions( XButton, YButton, AButton, BButton );

	// button 1/A/cross
	if ( AButton > 0 )
	{
		fPDA_Button1Tex	= fPDA_AButton_Active;
	}
	else
	if ( AButton < 0 )
	{
		fPDA_Button1Tex	= fPDA_AButton_Grey;
	}
	else
	{
		fPDA_Button1Tex	= fPDA_AButton_Ready;
	}

	// button 2/B/circle
	if ( BButton > 0 )
	{
		fPDA_Button2Tex	= fPDA_BButton_Active;
	}
	else
	if ( BButton < 0 )
	{
		fPDA_Button2Tex	= fPDA_BButton_Grey;
	}
	else
	{
		fPDA_Button2Tex	= fPDA_BButton_Ready;
	}

	// button 3/X/square
	if ( XButton > 0 )
	{
		fPDA_Button3Tex	= fPDA_XButton_Active;
	}
	else
	if ( XButton < 0 )
	{
		fPDA_Button3Tex	= fPDA_XButton_Grey;
	}
	else
	{
		fPDA_Button3Tex	= fPDA_XButton_Ready;
	}

	// button 4/Y/triangle
	if ( YButton > 0 )
	{
		fPDA_Button4Tex	= fPDA_YButton_Active;
	}
	else
	if ( YButton < 0 )
	{
		fPDA_Button4Tex	= fPDA_YButton_Grey;
	}
	else
	{
		fPDA_Button4Tex	= fPDA_YButton_Ready;
	}

	// DPad state
	switch ( fMenus[ fSelectedMenu ].fKeyDown )
	{
	case IK_Down:
		fPDA_DPadTex	= fPDA_DirDownTex;
		break;
	case IK_Up:
		fPDA_DPadTex	= fPDA_DirUpTex;
		break;
	case IK_Left:
		fPDA_DPadTex	= fPDA_DirLeftTex;
		break;
	case IK_Right:
		fPDA_DPadTex	= fPDA_DirRightTex;
		break;
	default:
		fPDA_DPadTex	= fPDA_DirReadyTex;
		break;
	}

	if ( AButton >= 0 )
	{
		fButton1Text	= fButtonOneLabel;
	}
	
	if ( BButton >= 0 )
	{
		fButton2Text	= fButtonTwoLabel;
	}
	
	if ( XButton >= 0 )
	{
		fButton3Text	= fButtonThreeLabel;
	}
	
	if ( YButton >= 0 )
	{
		fButton4Text	= fButtonFourLabel;
	}
}

function RemovePDAFromContollerList()
{
	local MenuUtility utils;

	log("Popping interation from PDA");
	PopInteraction(RootController, RootController.Player);

	utils = new(None) class'MenuUtility';
	utils.DirectAxisEnable(RootController, true);
}

function Think( canvas Canvas )
{
	log("PDA Base THinking Thinking");
	if( fSelectedMenu > -1)
	{
		fMenus[fSelectedMenu].Think( Canvas );
	}
}

defaultproperties
{
	fButtonOneLabel="ACCEPT"
	fButtonTwoLabel="BACK"
	fPDAMenuBacking=Texture'luna_textures_NS.Misc.black_bsp'
	fPDAUpperLeftCorner=Texture'B9HUD_textures.PDA_640x480.upper_corner'
	fPDATopSegment=Texture'B9HUD_textures.PDA_640x480.upper_segment'
	fPDATop=Texture'B9HUD_textures.PDA_640x480.top_center'
	fPDAUpperRightCorner=Texture'B9HUD_textures.PDA_640x480.upper_corner'
	fPDALeftSegment=Texture'B9HUD_textures.PDA_640x480.side_segment'
	fPDARightSegment=Texture'B9HUD_textures.PDA_640x480.side_segment'
	fPDALowerLeftCorner=Texture'B9HUD_textures.PDA_640x480.lower_corner'
	fPDALowerSegment1=Texture'B9HUD_textures.PDA_640x480.lower_segment'
	fPDALowerSegment2=Texture'B9HUD_textures.PDA_640x480.lower_segment'
	fPDALowerRightCorner=Texture'B9HUD_textures.PDA_640x480.lower_corner'
	fPDA_AButton_Grey=Texture'B9HUD_textures.PDA_640x480.A_button_grey'
	fPDA_AButton_Active=Texture'B9HUD_textures.PDA_640x480.A_button_active'
	fPDA_AButton_Ready=Texture'B9HUD_textures.PDA_640x480.A_button'
	fPDA_BButton_Grey=Texture'B9HUD_textures.PDA_640x480.B_button_grey'
	fPDA_BButton_Active=Texture'B9HUD_textures.PDA_640x480.B_button_active'
	fPDA_BButton_Ready=Texture'B9HUD_textures.PDA_640x480.B_button'
	fPDA_XButton_Grey=Texture'B9HUD_textures.PDA_640x480.X_button_grey'
	fPDA_XButton_Active=Texture'B9HUD_textures.PDA_640x480.X_button_active'
	fPDA_XButton_Ready=Texture'B9HUD_textures.PDA_640x480.X_button'
	fPDA_YButton_Grey=Texture'B9HUD_textures.PDA_640x480.Y_button_grey'
	fPDA_YButton_Active=Texture'B9HUD_textures.PDA_640x480.Y_button_active'
	fPDA_YButton_Ready=Texture'B9HUD_textures.PDA_640x480.Y_button'
	fPDA_AButton_Grey_PC=Texture'B9HUD_textures.PDA_640x480.A_button_PC_grey'
	fPDA_AButton_Active_PC=Texture'B9HUD_textures.PDA_640x480.A_button_PC_active'
	fPDA_AButton_Ready_PC=Texture'B9HUD_textures.PDA_640x480.A_button_PC'
	fPDA_BButton_Grey_PC=Texture'B9HUD_textures.PDA_640x480.B_button_PC_grey'
	fPDA_BButton_Active_PC=Texture'B9HUD_textures.PDA_640x480.B_button_PC_active'
	fPDA_BButton_Ready_PC=Texture'B9HUD_textures.PDA_640x480.B_button_PC'
	fPDA_XButton_Grey_PC=Texture'B9HUD_textures.PDA_640x480.X_button_PC_grey'
	fPDA_XButton_Active_PC=Texture'B9HUD_textures.PDA_640x480.X_button_PC_active'
	fPDA_XButton_Ready_PC=Texture'B9HUD_textures.PDA_640x480.X_button_PC'
	fPDA_YButton_Grey_PC=Texture'B9HUD_textures.PDA_640x480.Y_button_PC_grey'
	fPDA_YButton_Active_PC=Texture'B9HUD_textures.PDA_640x480.Y_button_PC_active'
	fPDA_YButton_Ready_PC=Texture'B9HUD_textures.PDA_640x480.Y_button_PC'
	fPDA_DirReadyTex=Texture'B9HUD_textures.PDA_640x480.directional'
	fPDA_DirDownTex=Texture'B9HUD_textures.PDA_640x480.directional_down'
	fPDA_DirUpTex=Texture'B9HUD_textures.PDA_640x480.directional_up'
	fPDA_DirLeftTex=Texture'B9HUD_textures.PDA_640x480.directional_left'
	fPDA_DirRightTex=Texture'B9HUD_textures.PDA_640x480.directional_right'
	fButtonLabelFont=Font'B9_Fonts.MicroscanA12'
	GUIScale=1
}