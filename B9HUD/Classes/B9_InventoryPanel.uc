//=============================================================================
// B9_InventoryPanel
//
// 
//	HUD object, display for Inventory Browser
// 
//=============================================================================


class B9_InventoryPanel extends B9_HUDPanel;


var private material			fBrowserFrameTex;
var private material			fAmmoFrameTex;
var private material			fClipIconTex;
var private material			fAmmoGaugeTex;
var private material			fBrowserArrowActiveTex;
var private material			fBrowserArrowInactiveTex;
var float						fBrowserStartLocation_X;
var float						fBrowserStartLocation_Y;

var font						fClipCounterFont;

var() localized string fAmmoFontName;

var B9_BasicPlayerPawn	fPlayerPawn;
var B9InventoryBrowser	fBrowser;

const ClipXSize = 11;
const ClipYSize = 27;

const kBrowserOffset_X = 256;
const kBrowserStartLocation_Y = 29;

const kWeapon_X = 75;
const kWeapon_Y = 25;
const kWeapon_Width  = 64;
const kWeapon_Height = 32;

const kItem_X = 143;
const kItem_Y = 25;
const kItem_Width  = 32;
const kItem_Height = 32;

const kSkill_X = 180;
const kSkill_Y = 25;
const kSkill_Width  = 32;
const kSkill_Height = 32;

const kWeapon_HighLighter_Size = 111;
const kWeapon_HighLighter_X = 100;
const kWeapon_HighLighter_Y = -15;
const kItem_HighLighter_X = 147;
const kItem_HighLighter_Y = -15;
const kSkill_HighLighter_X = 185;
const kSkill_HighLighter_Y = -15;

const ClipSizeX = 11;
const ClipSizeY = 27;

const kNonselected_Bottom_Y = 64;
const kNonselected_Top_Y = 3;

function PreBeginPlay()
{
	Super.PreBeginPlay();

	fClipCounterFont = Font( DynamicLoadObject( fAmmoFontName, class'Font' ) );
}



function bool GetOwnerInfo()
{
	local B9_HUD	myHUD;


	if ( fPlayerPawn == None )
	{
		myHUD	= B9_HUD( Owner );
		if ( myHUD != None )
		{
			fPlayerPawn	= B9_BasicPlayerPawn( myHUD.GetAdvancedPawn() );
			if ( fPlayerPawn != None )
			{
				fBrowser	= fPlayerPawn.fInventoryBrowser;
			}
		}
	}
	if ( fBrowser == None )
	{
		if ( fPlayerPawn != None )
		{
			fBrowser	= fPlayerPawn.fInventoryBrowser;
		}
	}

	return ( ( fPlayerPawn != None ) && ( fBrowser != None ) );
}




function Draw( Canvas canvas )
{
	local B9WeaponBase			gun;


	Super.Draw(Canvas);

	if ( !GetOwnerInfo() )
	{
		return;
	}

	fBrowserStartLocation_X = canvas.SizeX - kBrowserOffset_X;
	if( fBrowser.IsSelectorActive() == false )
	{
		fBrowserStartLocation_X = fBrowserStartLocation_X + 154.0;
	}

	if ( fBrowser == none )
	{
		return;
	}

 	if( fBrowser.IsSelectorActive() == true)
	{
		// Draw the main browser frame
		//
		DrawMainFrame( canvas );
	}

	// Get the player's gun
	// If he has a gun, draw the clip & ammo parts of the HUD
	//
	gun		= B9WeaponBase( fPlayerPawn.Weapon );
	
	if( gun != None )
	{
		if( gun.UsesClips() || gun.UsesAmmo() )
		{
			DrawAmmoFrame( canvas );

			// Draw clip counter
			//
			if( gun.UsesClips() )
			{
				DrawClipIcons( canvas, gun );
			}
			
			// Draw ammo gauge
			//
			if( gun.UsesAmmo() )
			{
				DrawAmmoGauge( canvas, gun );
			}
		}
	}
	

	
	// Draw selected objects
	//
	

	// If the selector is active, draw the hilighter
	// and the non-selected icons
	//
	if( fBrowser.IsSelectorActive() )
	{
		DrawSelectedObjects( canvas, fBrowser );
		DrawHilighter( canvas, fBrowser );
		DrawNonSelectedObjects( canvas, fBrowser );
	}

}


//////////////////////////////////////////////
// HOW THESE WORK
//
// startX/startY and endX/endY are the top,left and bottom,right corners
// in U,V of the texture file you are selecting to draw.
//
// posX/posY is the top,left corner in screen coordinates where the image will appear
//
// sizeX/sizeY the image is scaled to these dimensions
//
 
function DrawMainFrame( Canvas canvas )
{
	local int posX, posY, sizeX, sizeY, startX, startY, endX, endY;

	posX	= fBrowserStartLocation_X;
	posY	= kBrowserStartLocation_Y;
	sizeX	= 256;
	sizeY	= 128;
	startX	= 0;
	endX	= 256;
	startY	= 0;
	endY	= 128;

	Canvas.SetDrawColor( 255, 255, 255 );
	Canvas.Style = ERenderStyle.STY_Normal;

	Canvas.SetPos( posX, posY );
	Canvas.DrawTile( fBrowserFrameTex, sizeX, sizeY, startX, startY, endX, endY );
}

function DrawAmmoFrame( Canvas canvas )
{
	local int	posX, posY, sizeX, sizeY, startX, startY, endX, endY;


	posX	= fBrowserStartLocation_X;
	posY	= kBrowserStartLocation_Y;
	sizeX	= 256;
	sizeY	= 128;
	startX	= 0;
	endX	= 256;
	startY	= 0;
	endY	= 128;

	Canvas.SetDrawColor( 255, 255, 255 );
	Canvas.Style = ERenderStyle.STY_Normal;

	Canvas.SetPos( posX, posY );
	Canvas.DrawTile( fAmmoFrameTex, sizeX, sizeY, startX, startY, endX, endY );
}

function DrawClipIcons( Canvas canvas, B9WeaponBase gun )
{
	local int	numClips;
	local int	loop;


	// Number of clips
	//
	if( gun != None )
	{
		numClips	= ( gun.AmmoType.AmmoAmount - gun.ReloadCount ) / gun.Default.ReloadCount;
		if( numClips < 0 )
		{
			numClips = 0;
		}
		if( numClips > 5 )
		{
			numClips = 5;
		}

		
		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Normal;

		for ( loop = 0; loop < numClips ; loop ++ )
		{
			Canvas.SetPos( fBrowserStartLocation_X + 49 - ( ClipXSize + 1 ) * ( loop + 1 ), kBrowserStartLocation_Y + 14 );
			Canvas.DrawTile( fClipIconTex, ClipXSize, ClipYSize, 0, 0, ClipXSize, ClipYSize );
		}

	}
}

function DrawAmmoGauge( Canvas canvas, B9WeaponBase gun )
{
	local int		posX, posY, sizeX, sizeY, startX, startY, endX, endY;
	local float		numBulletsFired;
	local font		oldFont;
	local float		textWidth;
	local float		textHeight;


	posX	= fBrowserStartLocation_X;
	posY	= kBrowserStartLocation_Y;
	startX	= 0;
	endX	= 256;
	startY	= 0;
	endY	= 128;


	// Percent of ammo remaining in gun
	//
	if( gun != None )
	{
		// Draw the ammo bars
		//
		sizeX	= 5;
		sizeY	= 44;
		posX	= fBrowserStartLocation_X + 53;
		posY	= kBrowserStartLocation_Y + 19 + sizeY;
		startX	= 0;
		endX	= sizeX;
		startY	= 0;
		endY	= sizeY;
		if( gun.Default.ReloadCount != 0 )
		{
  			numBulletsFired =  FLOAT( gun.ReloadCount )/ FLOAT ( gun.Default.ReloadCount ) ;
		}

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Normal;

		Canvas.SetPos( posX, posY );
		Canvas.DrawTile( fAmmoGaugeTex, sizeX, -numBulletsFired * sizeY, startX, startY, endX, numBulletsFired * endY );
		
		/*
		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style	= ERenderStyle.STY_Normal;
		oldFont			= Canvas.Font;
		Canvas.Font		= fClipCounterFont;
		Canvas.TextSize( gun.ReloadCount, textWidth, textHeight );

		Canvas.SetPos( fBrowserStartLocation_X + 48 - textWidth, kBrowserStartLocation_Y + 47 );
		Canvas.DrawText( gun.ReloadCount, false );
		
		Canvas.Font	= oldFont;
		*/
		
	}
}



///////////////////////////////////////////////////////
// Object Icons
//


///////////////
// Selected
//

function DrawSelectedObjects( Canvas canvas, B9InventoryBrowser browser )
{
	DrawSelectedWeapon( canvas, browser );
	DrawSelectedItem( canvas, browser  );
	DrawSelectedSkill( canvas, browser );
}

function DrawSelectedWeapon( Canvas canvas, B9InventoryBrowser browser )
{
	local material	itemTex;
	local int		posX, posY, itemID;
	local Inventory		Inv;
	local B9WeaponBase	pWep;

	posX	= fBrowserStartLocation_X + kWeapon_X;
	posY	= kBrowserStartLocation_Y + kWeapon_Y;

	itemTex = browser.GetWeaponIcon( 1 );
	if( itemTex != none )
	{
		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;

		Canvas.SetPos( posX, posY );
		Canvas.DrawTile( itemTex, kWeapon_Width, kWeapon_Height, 0, 0, kWeapon_Width, kWeapon_Height );
	}
}

function DrawSelectedItem( Canvas canvas, B9InventoryBrowser browser )
{
	local material	itemTex;
	local int		posX, posY;

	posX	= fBrowserStartLocation_X + kItem_X;
	posY	= kBrowserStartLocation_Y + kItem_Y;

	itemTex = browser.GetItemIcon( 1 );
	if( itemTex != none )
	{
		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;

		Canvas.SetPos( posX, posY );
		Canvas.DrawTile( itemTex, kItem_Width, kItem_Height, 0, 0, kItem_Width, kItem_Height );
	}
}

function DrawSelectedSkill( Canvas canvas, B9InventoryBrowser browser )
{
	local material	itemTex;
	local int		posX, posY;

	posX	= fBrowserStartLocation_X + kSkill_X;
	posY	= kBrowserStartLocation_Y + kSkill_Y;

	itemTex = browser.GetSkillIcon( 1 );
	if( itemTex != none )
	{
		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;

		Canvas.SetPos( posX, posY );
		Canvas.DrawTile( itemTex, kSkill_Width, kSkill_Height, 0, 0, kSkill_Width, kSkill_Height );
	}
}


/////////////////
// Non-Selected
//

function DrawNonSelectedObjects( Canvas canvas, B9InventoryBrowser browser )
{
	DrawNonSelectedWeapons( canvas, browser );
	DrawNonSelectedItems( canvas, browser );
	DrawNonSelectedSkills( canvas, browser );
}

function DrawNonSelectedWeapons( Canvas canvas, B9InventoryBrowser browser )
{
	local material	itemTex;
	local int		posX, posY, sizeX, sizeY;

	// Bottom (next) first
	//
	itemTex = browser.GetWeaponIcon( 2 );
	if( itemTex != None )
	{
		posX	= fBrowserStartLocation_X + kWeapon_X + (kWeapon_Width / 4) ;
		posY	= kBrowserStartLocation_Y + kNonselected_Bottom_Y;
		sizeX	= kWeapon_Width / 2;
		sizeY	= kWeapon_Height / 2;

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;

		Canvas.SetPos( posX, posY );
		Canvas.DrawTile( itemTex, sizeX, sizeY, 0, 0, kWeapon_Width, kWeapon_Height );
	}

	// Now the top (previous)
	//
	itemTex = browser.GetWeaponIcon( 0 );
	if( itemTex != None )
	{
		posX	= fBrowserStartLocation_X + kWeapon_X + (kWeapon_Width / 4);
		posY	= kBrowserStartLocation_Y + kNonselected_Top_Y;
		sizeX	= kWeapon_Width / 2;
		sizeY	= kWeapon_Height / 2;

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;

		Canvas.SetPos( posX, posY );
		Canvas.DrawTile( itemTex, sizeX, sizeY, 0, 0, kWeapon_Width, kWeapon_Height );
	}
}

function DrawNonSelectedItems( Canvas canvas, B9InventoryBrowser browser )
{
	local material	itemTex;
	local int		posX, posY, sizeX, sizeY;

	// Bottom (next) first
	//
	itemTex = browser.GetItemIcon( 2 );
	if( itemTex != None )
	{
		posX	= fBrowserStartLocation_X + kItem_X + (kItem_Width / 4);
		posY	= kBrowserStartLocation_Y + kNonselected_Bottom_Y;
		sizeX	= kItem_Width / 2;
		sizeY	= kItem_Height / 2;

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;

		Canvas.SetPos( posX, posY );
		Canvas.DrawTile( itemTex, sizeX, sizeY, 0, 0, kItem_Width, kItem_Height );
	}

	// Now the top (previous)
	//
	itemTex = browser.GetItemIcon( 0 );
	if( itemTex != None )
	{
		posX	= fBrowserStartLocation_X + kItem_X + (kItem_Width / 4);
		posY	= kBrowserStartLocation_Y + kNonselected_Top_Y;
		sizeX	= kItem_Width / 2;
		sizeY	= kItem_Height / 2;

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;

		Canvas.SetPos( posX, posY );
		Canvas.DrawTile( itemTex, sizeX, sizeY, 0, 0, kItem_Width, kItem_Height );
	}
}

function DrawNonSelectedSkills( Canvas canvas, B9InventoryBrowser browser )
{
	local material	itemTex;
	local int		posX, posY, sizeX, sizeY;

	// Bottom (next) first
	//
	itemTex = browser.GetSkillIcon( 2 );
	if( itemTex != None )
	{
		posX	= fBrowserStartLocation_X + kSkill_X + (kSkill_Width / 4);
		posY	= kBrowserStartLocation_Y + kNonselected_Bottom_Y;
		sizeX	= kSkill_Width / 2;
		sizeY	= kSkill_Height / 2;

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;

		Canvas.SetPos( posX, posY );
		Canvas.DrawTile( itemTex, sizeX, sizeY, 0, 0, kSkill_Width, kSkill_Height );
	}

	// Now the top (previous)
	//
	itemTex = browser.GetSkillIcon( 0 );
	if( itemTex != None )
	{
		posX	= fBrowserStartLocation_X + kSkill_X + (kSkill_Width / 4);
		posY	= kBrowserStartLocation_Y + kNonselected_Top_Y;
		sizeX	= kSkill_Width / 2;
		sizeY	= kSkill_Height / 2;

		Canvas.SetDrawColor( 255, 255, 255 );
		Canvas.Style = ERenderStyle.STY_Translucent;

		Canvas.SetPos( posX, posY );
		Canvas.DrawTile( itemTex, sizeX, sizeY, 0, 0, 32, 32 );
	}
}



///////////////////////////////////////////////////////
// Highlighter
//

function DrawHilighter( Canvas canvas, B9InventoryBrowser browser )
{
	local int			itemID;
	local Inventory		Inv;
	local B9WeaponBase	pWep;
	local B9_Skill		pSkill;
	local B9_Powerups	pPwrUp;
	local B9_HUD		myHUD;
	local int			fTextLocation_X, fTextLocation_Y;
	local float			XL, YL;
	local B9_AccumulativeItem pAccumItem;
	local private string fPowerUpText;

	myHUD	= B9_HUD( Owner );

	fTextLocation_Y = kBrowserStartLocation_Y + kWeapon_HighLighter_Y + kWeapon_HighLighter_Size + YL;
	canvas.Font=font'B9_Fonts.MicroscanA12';

	// Determine which column is active
	//
	if( browser.GetSelectedColumn() == 0 )
	{
		DrawWeaponHilighter( canvas, browser );
	
		if( myHUD != None )
		{
			itemID = browser.GetSelectedWeapon();

			for( Inv = myHud.PlayerOwner.Pawn.Inventory; Inv != None; Inv = Inv.Inventory )
			{
				pWep = B9WeaponBase( Inv );
				
				if( ( pWep != none ) && ( pWep.fUniqueID == itemID ) )
				{
					canvas.TextSize( pWep.ItemName, XL, YL );
					fTextLocation_X = canvas.ClipX - 32 - XL;
					fTextLocation_Y = kBrowserStartLocation_Y + kWeapon_HighLighter_Y + kWeapon_HighLighter_Size + YL;
					canvas.SetPos( fTextLocation_X, fTextLocation_Y );
					canvas.DrawText( pWep.ItemName, False);
				}
			}
		}
	}
	else if( browser.GetSelectedColumn() == 1 )
	{
		DrawItemHilighter( canvas, browser );

		if( myHUD != None )
		{
			itemID = browser.GetSelectedItem();

			for( Inv = myHud.PlayerOwner.Pawn.Inventory; Inv != None; Inv = Inv.Inventory )
			{
				pPwrUp = B9_Powerups(Inv);
				pAccumItem = B9_AccumulativeItem(Inv);

				if( ( pPwrUp != none ) && ( pPwrUp.fUniqueID == itemID ) )
				{
					fPowerUpText = pPwrUp.ItemName;

					if( pAccumItem != None )
					{
						fPowerUpText =  fPowerUpText $ " : " $ pAccumItem.Amount;
					}

					canvas.TextSize( fPowerUpText, XL, YL );
					fTextLocation_X = canvas.ClipX - 32 - XL;
					fTextLocation_Y = kBrowserStartLocation_Y + kWeapon_HighLighter_Y + kWeapon_HighLighter_Size + YL;
					canvas.SetPos( fTextLocation_X, fTextLocation_Y );
					canvas.DrawText( fPowerUpText, False);
				}
			}
		}

	}
	else if( browser.GetSelectedColumn() == 2 )
	{
		DrawSkillHilighter( canvas, browser );

		if( myHUD != None )
		{
			itemID = browser.GetSelectedSkill();

			for( Inv = myHud.PlayerOwner.Pawn.Inventory; Inv != None; Inv = Inv.Inventory )
			{
				pSkill = B9_Skill( Inv );

				if( ( pSkill != none ) && ( pSkill.fUniqueID == itemID ) )
				{
					canvas.TextSize( pSkill.fSkillName, XL, YL );
					fTextLocation_X = canvas.ClipX - 32 - XL;
					fTextLocation_Y = kBrowserStartLocation_Y + kWeapon_HighLighter_Y + kWeapon_HighLighter_Size + YL;
					canvas.SetPos( fTextLocation_X, fTextLocation_Y );
					canvas.DrawText( pSkill.fSkillName, False);
				}
			}
		}
	}
}

function DrawWeaponHilighter( Canvas canvas, B9InventoryBrowser browser )
{
	local material	hilighterTexUp;
	local material	hilighterTexDown;
	local int posX, posY, sizeX, sizeY, startX, startY, endX, endY;


	// Determine texture to use
	// direction==-1 = no direction, use base texture
	// direction==1 = down (next)
	// direction==0 = up (previous)
	//
	if( browser.GetLastClickDirection() == -1 )
	{
		hilighterTexUp		= material'arrow_inactive_tex';
		hilighterTexDown	= material'arrow_inactive_tex';
	}
	if( browser.GetLastClickDirection() == 0 )
	{
		hilighterTexUp		= material'arrow_active_tex';
		hilighterTexDown	= material'arrow_inactive_tex';
	}
	if( browser.GetLastClickDirection() == 1 )
	{
		hilighterTexUp		= material'arrow_inactive_tex';
		hilighterTexDown	= material'arrow_active_tex';
	}


	// Now draw the tile
	//
	posX	= fBrowserStartLocation_X + kWeapon_HighLighter_X;
	posY	= kBrowserStartLocation_Y + kWeapon_HighLighter_Y;
	sizeX	= 32;
	sizeY	= 32;
	startX	= 0;
	endX	= 32;
	startY	= 0;
	endY	= 32;

	Canvas.SetDrawColor( 255, 255, 255 );
	Canvas.Style = ERenderStyle.STY_Normal;

	Canvas.SetPos( posX, posY );
	Canvas.DrawTile( hilighterTexUp, sizeX, sizeY, startX, startY, endX, endY );

	posY	= kBrowserStartLocation_Y + kWeapon_HighLighter_Y + kWeapon_HighLighter_Size;

	Canvas.SetPos( posX , posY );
	Canvas.DrawTile( hilighterTexDown, sizeX, -sizeY, startX, startY, endX, endY );


}

function DrawItemHilighter( Canvas canvas, B9InventoryBrowser browser )
{
	local material	hilighterTexUp;
	local material	hilighterTexDown;
	local int posX, posY, sizeX, sizeY, startX, startY, endX, endY;


	// Determine texture to use
	// direction==-1 = no direction, use base texture
	// direction==1 = down (next)
	// direction==0 = up (previous)
	//
	if( browser.GetLastClickDirection() == -1 )
	{
		hilighterTexUp		= material'arrow_inactive_tex';
		hilighterTexDown	= material'arrow_inactive_tex';
	}
	if( browser.GetLastClickDirection() == 0 )
	{
		hilighterTexUp		= material'arrow_active_tex';
		hilighterTexDown	= material'arrow_inactive_tex';
	}
	if( browser.GetLastClickDirection() == 1 )
	{
		hilighterTexUp		= material'arrow_inactive_tex';
		hilighterTexDown	= material'arrow_active_tex';
	}


	// Now draw the tile
	//
	posX	= fBrowserStartLocation_X + kItem_HighLighter_X;
	posY	= kBrowserStartLocation_Y + kItem_HighLighter_Y;
	sizeX	= 32;
	sizeY	= 32;
	startX	= 0;
	endX	= 32;
	startY	= 0;
	endY	= 32;

	Canvas.SetDrawColor( 255, 255, 255 );
	Canvas.Style = ERenderStyle.STY_Normal;

	Canvas.SetPos( posX, posY );
	Canvas.DrawTile( hilighterTexUp, sizeX, sizeY, startX, startY, endX, endY );

	posY	= kBrowserStartLocation_Y + kWeapon_HighLighter_Y + kWeapon_HighLighter_Size;

	Canvas.SetPos( posX , posY );
	Canvas.DrawTile( hilighterTexDown, sizeX, -sizeY, startX, startY, endX, endY );

}

function DrawSkillHilighter( Canvas canvas, B9InventoryBrowser browser )
{

	local material	hilighterTexUp;
	local material	hilighterTexDown;
	local int posX, posY, sizeX, sizeY, startX, startY, endX, endY;


	// Determine texture to use
	// direction==-1 = no direction, use base texture
	// direction==1 = down (next)
	// direction==0 = up (previous)
	//
	if( browser.GetLastClickDirection() == -1 )
	{
		hilighterTexUp		= material'arrow_inactive_tex';
		hilighterTexDown	= material'arrow_inactive_tex';
	}
	if( browser.GetLastClickDirection() == 0 )
	{
		hilighterTexUp		= material'arrow_active_tex';
		hilighterTexDown	= material'arrow_inactive_tex';
	}
	if( browser.GetLastClickDirection() == 1 )
	{
		hilighterTexUp		= material'arrow_inactive_tex';
		hilighterTexDown	= material'arrow_active_tex';
	}


	// Now draw the tile
	//
	posX	= fBrowserStartLocation_X + kSkill_HighLighter_X;
	posY	= kBrowserStartLocation_Y + kSkill_HighLighter_Y;
	sizeX	= 32;
	sizeY	= 32;
	startX	= 0;
	endX	= 32;
	startY	= 0;
	endY	= 32;

	Canvas.SetDrawColor( 255, 255, 255 );
	Canvas.Style = ERenderStyle.STY_Normal;

	Canvas.SetPos( posX, posY );
	Canvas.DrawTile( hilighterTexUp, sizeX, sizeY, startX, startY, endX, endY );

	posY	= kBrowserStartLocation_Y + kWeapon_HighLighter_Y + kWeapon_HighLighter_Size;

	Canvas.SetPos( posX , posY );
	Canvas.DrawTile( hilighterTexDown, sizeX, -sizeY, startX, startY, endX, endY );

}




defaultproperties
{
	fBrowserFrameTex=Texture'B9HUD_textures.Browser.item_skill_browser_tex'
	fAmmoFrameTex=Texture'B9HUD_textures.Browser.ammo_status_tex'
	fClipIconTex=Texture'B9HUD_textures.Browser.ammo_clip_tex'
	fAmmoGaugeTex=Texture'B9HUD_textures.Browser.ammo_bar_tex'
	fBrowserArrowActiveTex=Texture'B9HUD_textures.Browser.arrow_active_tex'
	fBrowserArrowInactiveTex=Texture'B9HUD_textures.Browser.arrow_inactive_tex'
	fBrowserStartLocation_X=384
	fBrowserStartLocation_Y=29
	fAmmoFontName="B9_Fonts.MicroscanA16"
}