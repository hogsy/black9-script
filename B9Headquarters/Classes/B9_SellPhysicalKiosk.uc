/////////////////////////////////////////////////////////////
// B9_SellPhysicalKiosk
//

class B9_SellPhysicalKiosk extends B9_BaseKiosk;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX
#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures
#exec OBJ LOAD FILE=..\textures\B9MenuHelp_Textures.utx PACKAGE=B9MenuHelp_Textures

var private bool bOverSell;

var localized string fStrConfirmMsg;
var localized string fStrSell;
var localized string fStrValue;
var localized string fStrNothingToSell;

var vector LastLocation;
var rotator LastRotation;

var array<B9_HoloItem> Stock;
var int FrontIndex;
var float ratio;

var B9_PageBrowser DescriptionView;
var array<string> DescriptionBody;

var float fSelectAnimTicks;
var bool fSelectReverse;

var texture fMultiFrameTop;
var texture fMultiFrameMiddle;
var texture fMultiFrameBottom;
var texture fMultiFrameSubtitle;
var texture fMultiFrameTopQuarter;
var texture fSingleLineFrame;
var texture fKioskInfoLeft;
var texture fKioskInfoRight;
var texture fBackImage;
var texture fFullFrameTopLeft;
var texture fFullFrameTopRight;
var texture fFullFrameBottomLeft;
var texture fFullFrameBottomRight;

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	local B9_PlayerController pc;

	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
		DescriptionView = new(None) class'B9_PageBrowser';
		DescriptionBody.Length = 1;
	}
}

function MenuExit()
{
	local int i;

	Super.MenuExit();

	for (i=0;i<Stock.Length;i++)
		if (Stock[i] != None)
			Stock[i].Destroy();
}

function Tick(float Delta)
{
	local int i;
	local bool changed;
	local Pawn pawn;

	Super.Tick(Delta);

	if (fSelectAnimTicks > 0f)
	{
		fSelectAnimTicks -= Delta;
		if (fSelectAnimTicks <= 0f)
		{
			fSelectAnimTicks = 0f;
			if (fKeyDown == IK_Up) 
			{
				ChangeSelection(true);
			}
			else if (fKeyDown == IK_Down) 
			{
				ChangeSelection(false);
			}
/*
			else if (fKeyDown == IK_LeftMouse)
			{
				if (!bOverSell)
					ChangeSelection(MouseY < 320);
			}
*/
			else
			{
				for (i=0;i<Stock.Length;i++)
					SetItemPositioning(i);
				changed = true;
			}
		}
	}


	pawn = RootController.Pawn;
	if (LastLocation != pawn.Location || LastRotation != pawn.Rotation)
	{
		if (!changed)
			for (i=0;i<Stock.Length;i++)
				SetItemPositioning(i);
		LastLocation = pawn.Location;
		LastRotation = pawn.Rotation;
	}
}

function RenderDisplay( canvas Canvas )
{
	RenderStockList( Canvas );
}

function SetItemPositioning(int i)
{
	local B9_HoloItem item;
	local Pawn pawn;
	local vector loc, XAxis, YAxis, ZAxis;
	local float x, y;
	local float k;
	local float angle, arc;

	item = Stock[i];
	pawn = RootController.Pawn;

	GetAxes(TriggerRot, Xaxis, Yaxis, Zaxis);
	//GetAxes(pawn.Rotation, Xaxis, Yaxis, Zaxis);
	loc = pawn.Location;

	k = (i - FrontIndex + Stock.Length) % Stock.Length;

	arc = 2 * PI / float(Stock.Length);
	angle = k * arc;

	if (fSelectAnimTicks > 0f)
	{
		if (fSelectReverse)
			angle -= arc * fSelectAnimTicks / 1.0f;
		else
			angle += arc * fSelectAnimTicks / 1.0f;

		item.SetDrawScale(1.0f);
	}
	else if (i == FrontIndex)
	{
		item.SetDrawScale(2.0f);
	}
	else
	{
		item.SetDrawScale(1.0f);
	}

	x = -cos(angle);
	y = Listener.KioskHoloHeight * sin(angle) * 0.5f;

	loc += Xaxis * (Listener.KioskHoloOffset + x * Listener.KioskHoloWidth * 0.5f) +
		ZAxis * y + Listener.KioskHoloShift * YAxis;
	loc.Z += pawn.Eyeheight;
	item.SetLocation( loc );
}

function bool FindPrice(B9_HoloItem item, array<string> stock, float scale)
{
	local int i, j;
	local string s, iname;

	iname = item.InventoryName $ ",";

	for (i=0;i<stock.Length;i++)
	{
		s = stock[i];

		j = InStr(s, iname);
		if (j == 0)
		{
			s = Mid(s, Len(item.InventoryName) + 1);
			j = InStr(s, ",");
			if (j == -1)
				item.FullPrice = float(s);
			else
				item.FullPrice = float(Left(s, j));
			item.Price = float(item.FullPrice) * scale;
			return true;
		}
	}

	return false;
}

function StockFromInventory(array<Class> BaseClasses, array<string> ClassPackage, bool weapon)
{
	local Inventory inventory;
	local string invClassName;
	local class<B9_HoloItem> ItemClass;
	local B9_HoloItem item;
	local int i, n;
	local B9_Intermission intermission;
	local bool found;
	local float ratio;
	local Pawn pawn;

	pawn = RootController.Pawn;
	LastLocation = pawn.Location;
	LastRotation = pawn.Rotation;
	fSelectAnimTicks = 0.0001;

	inventory = pawn.Inventory;
	intermission = Listener.Intermission;

	// does player already have item?
	while (inventory != None)
	{
		for (i=0;i<BaseClasses.Length;i++)
		{
			if ( ClassIsChildOf(inventory.Class, BaseClasses[i]) && 
				!ClassIsChildOf(inventory.Class, class'B9Weapons.HandToHand') )
			{
				invClassName = ClassPackage[i] $ "." $ string(inventory.Class.Name);

				Log("StockFromInventory: " $ invClassName);

				ItemClass = class<B9_HoloItem>(DynamicLoadObject(invClassName $ "_Holo", class'Class'));
				if (ItemClass == None) continue;

				item = RootController.spawn(ItemClass);
				if (item != None)
				{
					// figure out price
					found = false;
					ratio = intermission.SellToPurchasePriceRatio;
					if (weapon)
					{
						found = FindPrice(item, intermission.FirearmsKioskStock, ratio);
						if (!found)
							found = FindPrice(item, intermission.HeavyWeaponsKioskStock, ratio);
						if (!found)
							found = FindPrice(item, intermission.ExplosivesKioskStock, ratio);
						if (!found)
							found = FindPrice(item, intermission.MeleeWeaponsKioskStock, ratio);
						if (!found)
							found = FindPrice(item, intermission.SpecialWeaponsKioskStock, ratio);
					}
					else
					{
						found = FindPrice(item, intermission.ArmorKioskStock, ratio);
						if (!found)
							found = FindPrice(item, intermission.ReconGearKioskStock, ratio);
						if (!found)
							found = FindPrice(item, intermission.BiomedGearKioskStock, ratio);
						if (!found)
							found = FindPrice(item, intermission.AddonGearKioskStock, ratio);
						if (!found)
							found = FindPrice(item, intermission.EnvironmentGearKioskStock, ratio);
						if (!found)
							found = FindPrice(item, intermission.MiscGearKioskStock, ratio);
					}

					if (!found)
						found = FindPrice(item,intermission.AmmoPrices, ratio);
					if (!found)
						found = FindPrice(item,intermission.OtherPrices, ratio);

					if (item.price == 0)
						item.price = 1;

					item.RealItem = inventory;

					n = Stock.Length;
					Stock.Length = n + 1;
					Stock[n] = item;
				}
				break;
			}
		}

		inventory = inventory.Inventory;
	}

	// let Tick() do it, see fSelectAnimTicks above
	//for (i=0;i<Stock.Length;i++)
	//	SetItemPositioning(i);

	// !!!! Other possibilities: merge same weapons into one entry (this would require
	//		making RealItem a dynamic list).
}

function RenderStockList( canvas Canvas )
{
	local color white, cyan;
	local color textColor, shadowColor, btnColor;
	local font oldFont;
	local int i;
	local B9_HoloItem item;
	local B9_HoloItem frontItem;
	local vector loc;
	local bool ClearZ;
	local float oldOrgX, oldOrgY;
	local float oldClipX, oldClipY;
	local string msg;
	local int x, y;
	local float sx, sy;

	oldFont = Canvas.Font;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	cyan.R = 0;
	cyan.G = 255;
	cyan.B = 255;

	textColor.R = 255;
	textColor.G = 255;
	textColor.B = 255;

	shadowColor.R = 0;
	shadowColor.G = 0;
	shadowColor.B = 0;

	ClearZ = true;

	Canvas.Style = RootController.ERenderStyle.STY_Normal;
	Canvas.SetDrawColor(white.R, white.G, white.B);

	oldOrgX = Canvas.OrgX;
	oldOrgY = Canvas.OrgY;
	oldClipX = Canvas.ClipX;
	oldClipY = Canvas.ClipY;

	for (i=0;i<Stock.Length;i++)
	{
		item = Stock[i];
		if (item != None)
		{
			if (fSelectAnimTicks > 0f)
			{
				SetItemPositioning(i);
			}
			else if (FrontIndex == i)
			{
				frontItem = item;
			}

			Canvas.SetDrawColor(white.R, white.G, white.B);
			Canvas.DrawActor( item, false, ClearZ );
			ClearZ = false;
		}
		else
		{
			Canvas.Font = fMyFont16;
			Canvas.SetPos( 50, 10 + 24 * i );
			Canvas.DrawText( "Missing item #" $ string(i), false );
		}
	}

	item = frontItem;
	if (item != None)
	{
		Canvas.SetDrawColor(white.R, white.G, white.B);
		Canvas.Style = RootController.ERenderStyle.STY_Normal;
	
		x = 320 - 256;
		y = 480 - 52;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fKioskInfoLeft, 256, 32, 0, 0, 256, 32 );

		x += 256;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fKioskInfoRight, 256, 32, 0, 0, 256, 32 );

		x = 320 - 128;
		y = 20;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fMultiFrameTopQuarter, 256, 32, 0, 0, 256, 32 );

		x = 320 - 256;
		y += 32;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fMultiFrameSubtitle, 256, 32, 0, 0, 256, 32 );

		y -= 32;
		Canvas.Font = fMyFont24;
		Canvas.TextSize(fStrSell, sx, sy);
		Canvas.SetPos( x + 196 - sx / 2.0, y + 8 );
		Canvas.DrawText(fStrSell);

		y += 40;
		Canvas.Font = fMyFont16;
		Canvas.TextSize(item.DisplayName, sx, sy);
		Canvas.SetPos( x + 128 - sx / 2.0, y );
		Canvas.DrawText(item.DisplayName);

		y += 10 + 24;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fMultiFrameTop, 256, 32, 0, 0, 256, 32 );

		for (i=0;i<7;i++)
		{
			y += 32;
			Canvas.SetPos( x, y );
			Canvas.DrawTile( fMultiFrameMiddle, 256, 32, 0, 0, 256, 32 );
		}

		y += 32;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fMultiFrameBottom, 256, 32, 0, 0, 256, 32 );

		Canvas.SetOrigin(RootInteraction.OriginX + x + 16, 
			RootInteraction.OriginY + y - 8 * 32 + 12); 
		Canvas.SetClip(256 - 32, 8 * 32 - 24); 

		DescriptionBody[0] = item.Description;
		DescriptionView.RenderPage( Canvas, DescriptionBody, 512, false );

		Canvas.SetOrigin(oldOrgX, oldOrgY); 
		Canvas.SetClip(oldClipX, oldClipY); 

		y += 42;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fSingleLineFrame, 256, 32, 0, 0, 256, 32 );

		Canvas.SetPos( x + 10, y + 8);
		Canvas.DrawText(fStrValue);

		msg = "$" $ string(item.Price);
		Canvas.TextSize(msg, sx, sy);
		Canvas.SetPos( x + 256 - 10 - sx, y + 8);
		Canvas.DrawText(msg);
	}
	else if (Stock.Length == 0) // nothing to sell
	{
		Canvas.SetDrawColor(white.R, white.G, white.B);
		Canvas.Style = RootController.ERenderStyle.STY_Normal;

		x = 320 - 256;
		y = 200;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fFullFrameTopLeft, 256, 32, 0, 0, 256, 32 );

		x += 256;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fFullFrameTopRight, 256, 32, 0, 0, 256, 32 );

		x = 320 - 256;
		y += 32;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fFullFrameBottomLeft, 256, 32, 0, 0, 256, 32 );

		x += 256;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fFullFrameBottomRight, 256, 32, 0, 0, 256, 32 );

		Canvas.Font = fMyFont24;
		Canvas.TextSize(fStrNothingToSell, sx, sy);
		Canvas.SetPos( x - sx / 2.0, y - 32 + 20 );
		Canvas.DrawText(fStrNothingToSell);
	}

	Canvas.Font = fMyFont16;
	Canvas.Style = RootController.ERenderStyle.STY_Normal;
	DrawTextWithShadow( Canvas,
		"$" $ string(B9_PlayerPawn(RootController.Pawn).fCharacterCash),
		20, 20, white, shadowColor, 2 );

/*
	if (bDrawMouse)
	{
		Canvas.TextSize(fStrSell, sx, sy);

		if (fKeyDown == IK_None)
		{
			bOverSell = (ChildInteraction == None &&
				MouseX >= 50 && MouseX < 50 + sx && MouseY >= 300 && MouseY < 300 + sy);
		}
		
		if (bOverSell) btnColor = white;
		else btnColor = cyan;
		DrawTextWithShadow( Canvas, fStrSell, 50, 300, btnColor, shadowColor, 2 );
	}
*/

	Canvas.Font = oldFont;
}

function ChangeSelection(bool rev)
{
	if (rev)
	{
		FrontIndex = (FrontIndex - 1 + Stock.Length) % Stock.Length;
		fSelectReverse = true;
		RootController.PlaySound( fUpSound );
	}
	else
	{
		FrontIndex = (FrontIndex + 1) % Stock.Length;
		fSelectReverse = false;
		RootController.PlaySound( fDownSound );
	}
	fSelectAnimTicks = 1.0f;
}

/*
function ConfirmSell()
{
	local B9_ConfirmInteraction confirm;

	MakeChildInteraction("B9Headquarters.B9_ConfirmInteraction");

	confirm = B9_ConfirmInteraction(ChildInteraction);
	if (confirm != None)
	{
		confirm.SetMessage(	fStrConfirmMsg );
	}
}
*/

function Sell()
{
	local float dist, Bdist;
	local B9_HoloItem item;
	local class<B9_HoloItem> ItemClass;
	local int i;

	item = Stock[FrontIndex];
	B9_PlayerPawn(RootController.Pawn).HQSellItem(item.RealItem, item.FullPrice);
	item.RealItem = None;

	Stock.Remove(FrontIndex, 1);
/*
	if (Stock.Length == 0)
	{
		// Exit kiosk if all item in this catagory sold.
		MenuExit();
	}
	else
	{
*/
		if (FrontIndex == Stock.Length)
		{
			FrontIndex = 0;
		}

		for (i=0;i<Stock.Length;i++)
			SetItemPositioning(i);
/*
	}
*/
}

function EndMenu(B9_MenuInteraction interaction, int result)
{
	if (interaction == ChildInteraction)
	{
		ChildInteraction = None;
		bIgnoreEvent = true;
		fKeyDown = IK_None;

		if (result == 0) // sell it!
		{
			Sell();
		}
	}
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	local B9_PlayerController pc;
	local bool result;

	if (Super.KeyEvent( Key, Action, Delta ) || bIgnoreEvent || ChildInteraction != None)
	{
		bIgnoreEvent = false;
		return true;
	}

	Key = ConvertJoystick(Key);

	if( Action == IST_Press && (Key == IK_Enter || Key == IK_Space ||
		Key == IK_LeftMouse || Key == IK_Joy1) )
	{
		if (fKeyDown == IK_None)
		{
			fKeyDown = IK_LeftMouse;
			//if (!bOverSell) ChangeSelection(MouseY < 320);
		}
	}
	else if( Action == IST_Release && (Key == IK_Enter || Key == IK_Space ||
		Key == IK_LeftMouse || Key == IK_Joy1) )
	{
		if (fKeyDown == IK_LeftMouse)
		{
			//if (bOverSell)
			//{
				RootController.PlaySound( fClickSound );
				// ConfirmSell(); // !!!! enable later
				Sell(); // !!!! for now
			//}
			fKeyDown = IK_None;
		}
	}
	else if ( Action == IST_Press && (Key == IK_Backspace || Key == IK_Escape ||
		Key == IK_RightMouse || Key == IK_Joy2) )
	{
		if (fKeyDown == IK_None)
			fKeyDown = IK_RightMouse;
	}
	else if ( Action == IST_Release && (Key == IK_Backspace || Key == IK_Escape ||
		Key == IK_RightMouse || Key == IK_Joy2) )
	{
		if (fKeyDown == IK_RightMouse)
		{
			RootController.PlaySound( fCancelSound );
			MenuExit();
			fKeyDown = IK_None;
		}
	}
	else if( Action == IST_Press && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
	{
		if (fKeyDown == IK_None)
		{
			ChangeSelection(true);
			fKeyDown = IK_Up;
		}
	}
	else if( Action == IST_Release && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
	{
		if (fKeyDown == IK_Up)
			fKeyDown = IK_None;
	}
	else if( Action == IST_Press && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
	{
		if (fKeyDown == IK_None)
		{
			ChangeSelection(false);
			fKeyDown = IK_Down;
		}
	}
	else if( Action == IST_Release && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
	{
		if (fKeyDown == IK_Down)
			fKeyDown = IK_None;
	}

	return true;
}

defaultproperties
{
	fStrConfirmMsg="Are you sure you want to sell this item?"
	fStrSell="SELL"
	fStrValue="Value:"
	fStrNothingToSell="You have nothing to sell."
	fMultiFrameTop=Texture'B9Menu_textures.Half_Size_Panes.multi_frame_red_top'
	fMultiFrameMiddle=Texture'B9Menu_textures.Half_Size_Panes.multi_frame_red_middle'
	fMultiFrameBottom=TexScaler'B9Menu_textures.Half_Size_Panes.multi_frame_red_bottom'
	fMultiFrameSubtitle=Texture'B9Menu_textures.Half_Size_Panes.multi_frame_red_subtitle_quarter'
	fMultiFrameTopQuarter=Texture'B9Menu_textures.Half_Size_Panes.multi_frame_top_red_quarter'
	fSingleLineFrame=Texture'B9Menu_textures.Half_Size_Panes.single_line_red_frame'
	fKioskInfoLeft=Texture'B9MenuHelp_Textures.Choices.kiosk_info_1_left'
	fKioskInfoRight=Texture'B9MenuHelp_Textures.Choices.kiosk_info_1_right_sell'
	fBackImage=Texture'B9MenuHelp_Textures.Choices.choice_back'
	fFullFrameTopLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_left'
	fFullFrameTopRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_top_right'
	fFullFrameBottomLeft=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_left'
	fFullFrameBottomRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_right'
	fBackOffPawn=60
	fFOV=105
	fUpSound=Sound'B9SoundFX.Menu.up_1'
	fDownSound=Sound'B9SoundFX.Menu.down_1'
	fClickSound=Sound'B9SoundFX.Menu.ok_1'
	fCancelSound=Sound'B9SoundFX.Menu.cancel_2'
}