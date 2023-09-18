/////////////////////////////////////////////////////////////
// B9_BuyPhysicalKiosk
//

class B9_BuyPhysicalKiosk extends B9_BaseKiosk;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX
#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures
#exec OBJ LOAD FILE=..\textures\B9MenuHelp_Textures.utx PACKAGE=B9MenuHelp_Textures

var name PickupDropTagName;

var private bool bOverPurchase;
var private bool bCanBuy;
var private bool bUnavailable;

var bool fIsWeaponKiosk;
var bool fConvertToAmmo;

var localized string fStrPurchase;
var localized string fStrInsufficentFunds;
var localized string fStrUnavailable;

var localized string fStrConfirmMsg;
var localized string fStrRestrictedMsg;
var localized string fStrTooWeakMsg;
var localized string fStrCost;
var localized string fStrNothingToBuy;

var localized string fStrCategoryName;

var vector LastLocation;
var rotator LastRotation;

var array<B9_HoloItem> Stock;
var int FrontIndex;
var int MaxWeapons;
var int WeaponCount;

var B9_PageBrowser DescriptionView;
var array<string> DescriptionBody;

var float fSelectAnimTicks;
var bool fSelectReverse;

var texture fMultiFrameTop;
var texture fMultiFrameMiddle;
var texture fMultiFrameBottom;
var texture fMultiFrameSubtitle;
var texture fSingleLineFrame;
var texture fKioskInfoLeft;
var texture fKioskInfoRight;
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
		DescriptionBody.Length = 2;

		fStrRestrictedMsg = "<font color=\"yellow\">" $ fStrRestrictedMsg;
		fStrTooWeakMsg = "<font color=\"yellow\">" $ fStrTooWeakMsg;
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

	Super.Tick( Delta );

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
				if (!bOverPurchase) ChangeSelection(MouseY < 320);
			}
*/
			else
			{
				changed = true;
			}
		}
	}

	pawn = RootController.Pawn;
	if (LastLocation != pawn.Location || LastRotation != pawn.Rotation)
	{
		LastLocation = pawn.Location;
		LastRotation = pawn.Rotation;
		changed = true;
	}

	if (changed)
	{
		for (i=0;i<Stock.Length;i++)
			SetItemPositioning(i);
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

	//GetAxes(TriggerRot, Xaxis, Yaxis, Zaxis);
	GetAxes(pawn.Rotation, Xaxis, Yaxis, Zaxis);
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
		ZAxis * y - Listener.KioskHoloShift * YAxis;
	loc.Z += pawn.Eyeheight;
	item.SetLocation( loc );
	item.SetRotation( Pawn.Rotation );
}

function bool CheckPawnInventory(class TheClass, out B9_HoloItem item, bool noWeapons)
{
	local class<B9_HoloItem> ItemClass;
	local B9_HoloItem ammo;
	local array<string> prices;
	local string s;
	local int i;
	local Pickup Pickup;
	local bool pending;
	local Inventory inventory;
	local class<Ammunition> AmmoClass;

	log("CheckPawnInventory: " $ item.DisplayName $ " " $ item.AmmoName);

	if ( !noWeapons || !ClassIsChildOf(TheClass, class'Weapon') ||
		ClassIsChildOf(TheClass, class'GrapplingHook') )
	{
		// does player already have item?
		inventory = RootController.Pawn.Inventory;
		while (inventory != None)
		{
			log("CheckPawnInventory  : " $ inventory.Name);

			if (ClassIsChildOf(inventory.Class, TheClass) && ClassIsChildOf(TheClass, inventory.Class))
				break;

			inventory = inventory.Inventory;
		}

		// at this point, inventory is just a flag
		if (inventory == None)
		{
			// Has the player bought the item but not picked it up yet?
			ForEach RootController.Pawn.Region.Zone.ZoneActors(class'Pickup', Pickup)
			{
				if (Pickup.Tag == B9_PlayerPawn(RootController.Pawn).fServerName && 
					Pickup.InventoryType == TheClass)
				{
					pending = true;
					break;
				}
			}

			if (!pending)
				return false;
		}
	}

	if (Len(item.AmmoName) == 0)
	{
		if (!item.CanAggregate)
		{
			item.Destroy();
			item = None;
		}

		return false;
	}

	ConvertToAmmo(-1, item);

	return (item != None);
}

function StockStatus()
{
	local B9_HoloItem item;

	if (Stock.Length > 0)
	{
		item = Stock[FrontIndex];
		bUnavailable = (item.Restricted ||
			item.RequiredStrength > B9_PlayerPawn(RootController.Pawn).fCharacterStrength);
		bCanBuy = (!bUnavailable && B9_PlayerPawn(RootController.Pawn).fCharacterCash >= item.Price);
	}
}

function StockItems(array<string> items)
{
	local int i, j, n;
	local B9_HoloItem item;
	local class<B9_HoloItem> ItemClass;
	local class<Actor> ActorClass;
	local string cname;
	local int price;
	local Pawn pawn;
	local Class TheClass;
	local bool restricted;
	local bool converted;
	local string itemStr;
	local Inventory inventory;

	pawn = RootController.Pawn;
	LastLocation = pawn.Location;
	LastRotation = pawn.Rotation;
	fSelectAnimTicks = 0.0001;

	MaxWeapons = B9_BasicPlayerPawn(pawn).kMaxPlayerWeapons;
	if (fIsWeaponKiosk)
	{
		inventory = pawn.Inventory;
		while (inventory != None)
		{
			if ( inventory.IsA('Weapon') && !inventory.IsA('GrapplingHook') )
				WeaponCount++;
			inventory = inventory.Inventory;
		}
	}

	// items[i] is encoded: class,price

	Stock.Length = items.Length; // this may go down after dups of ammo are removed

	for (i=0;i<items.Length;i++)
	{
		restricted = false;
		itemStr = items[i];
		if (Left(itemStr,1) == "*")
		{
			restricted = true;
			itemStr = Mid(itemStr, 1);
		}

		n = InStr(itemStr, ",");
		if (n == -1)
		{
			cname = itemStr;
			price = 1;
		}
		else
		{
			cname = Left(itemStr, n);
			price = int(Mid(itemStr, n + 1));
		}

		ItemClass = class<B9_HoloItem>(DynamicLoadObject(cname $ "_Holo", class'Class'));

		if (ItemClass != None)
		{
			item = RootController.spawn(ItemClass);
			if (item != None)
			{
				item.Price = price;
				item.Restricted = restricted;
				item.KioskData = items[i];

				TheClass = class(DynamicLoadObject(cname, class'Class'));

				if (item.RemoveFromStock(pawn, TheClass, None))
				{
					item.Destroy();
					item = None;
					continue;
				}

				converted = CheckPawnInventory(TheClass, item, MaxWeapons <= WeaponCount);
				if (item == None)
					continue;

				// don't show same item twice (usually ammo related)
				for (j=0;j<i;j++)
				{
					if (Stock[j] != None && ClassIsChildOf(Stock[j].Class, item.Class) &&
						ClassIsChildOf(item.Class, Stock[j].Class))
					{
						// dup!
						item.Destroy();
						item = None;
						break;
					}
				}
				if (item == None)
					continue;

/*
				if (item.AmmoName != "")
				{
					ItemClass = class<B9_HoloItem>(DynamicLoadObject(item.AmmoName $ "_Holo", class'Class'));
					if (ItemClass != None)
						item.HoloAmmo = new(None) ItemClass;
				}
*/

				if (!converted && ClassIsChildOf(TheClass, class'Weapon') &&
					!ClassIsChildOf(TheClass, class'GrapplingHook'))
				{
					item.IsWeapon = true;
				}

				Stock[i] = item;
				//SetItemPositioning(i); // let Tick() do it, see fSelectAnimTicks above
			}
		}
	}

	// remove empty entries
	for (i=0;i<Stock.Length;i++)
	{
		if (Stock[i] == None)
		{
			Stock.Remove(i, 1);
			--i;
		}
	}

	StockStatus();
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

			Canvas.SetDrawColor(cyan.R, cyan.G, cyan.B);
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

		x = 320;
		y = 20;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fMultiFrameTop, 256, 32, 0, 0, 256, 32 );

		y += 32;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fMultiFrameSubtitle, 256, 32, 0, 0, 256, 32 );

		y -= 32;
		Canvas.Font = fMyFont24;
		Canvas.TextSize(fStrCategoryName, sx, sy);
		Canvas.SetPos( x + 128 - sx / 2.0, y + 8 );
		Canvas.DrawText(fStrCategoryName);

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
		if (item.Restricted)
			DescriptionBody[1] = fStrRestrictedMsg;
		else if (item.RequiredStrength > B9_PlayerPawn(RootController.Pawn).fCharacterStrength)
			DescriptionBody[1] = fStrTooWeakMsg;
		else
			DescriptionBody[1] = "";
		DescriptionView.RenderPage( Canvas, DescriptionBody, 512, false );

		Canvas.SetOrigin(oldOrgX, oldOrgY); 
		Canvas.SetClip(oldClipX, oldClipY); 

		y += 42;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fSingleLineFrame, 256, 32, 0, 0, 256, 32 );

		Canvas.SetPos( x + 10, y + 8);
		Canvas.DrawText( GetLeftSummary(item) );

		msg = GetRightSummary(item);
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

		Canvas.Font = fMyFont20;
		Canvas.TextSize(fStrNothingToBuy, sx, sy);
		Canvas.SetPos( x - sx / 2.0, y - 32 + 20 );
		Canvas.DrawText(fStrNothingToBuy);
	}

	Canvas.Font = fMyFont16;
	Canvas.Style = RootController.ERenderStyle.STY_Normal;
	DrawTextWithShadow( Canvas,
		"$" $ string(B9_PlayerPawn(RootController.Pawn).fCharacterCash),
		20, 20, white, shadowColor, 2 );

/*
	if (bDrawMouse)
	{
		Canvas.TextSize(fStrPurchase, sx, sy);

		if (fKeyDown == IK_None)
		{
			bOverPurchase = (bCanBuy && ChildInteraction == None &&
				MouseX >= 50 && MouseX < 50 + sx && MouseY >= 300 && MouseY < 300 + sy);
		}
		
		if (bOverPurchase) btnColor = white;
		else btnColor = cyan;
		if (bUnavailable) msg = fStrUnavailable;
		else if (bCanBuy) msg = fStrPurchase;
		else msg = fStrInsufficentFunds;
		DrawTextWithShadow( Canvas, msg, 50, 300, btnColor, shadowColor, 2 );
	}
*/

	Canvas.Font = oldFont;
}

function string GetLeftSummary(B9_HoloItem item)
{
	return fStrCost;
}

function string GetRightSummary(B9_HoloItem item)
{
	return "$" $ string(item.Price);
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

	StockStatus();
}

/*
function ConfirmPurchase()
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

function ConvertToAmmo(int index, out B9_HoloItem item)
{
	local B9_HoloItem ammo;
	local class<B9_HoloItem> ItemClass;
	local class<Ammunition> AmmoClass;
	local array<string> prices;
	local Inventory inventory;
	local string s;
	local int i;

	if (!fConvertToAmmo)
	{
		if (index >= 0)
		{
			Stock.Remove(index, 1);
			if (FrontIndex == Stock.Length)
				FrontIndex = 0;
		}
		item.Destroy();
		item = None;
		return;
	}

	ItemClass = class<B9_HoloItem>(DynamicLoadObject(item.AmmoName $ "_Holo", class'Class'));
	if (ItemClass != None)
	{
		for (i=0;i<Stock.Length;i++)
		{
			if (ClassIsChildOf(Stock[i].Class, ItemClass) &&
				ClassIsChildOf(ItemClass, Stock[i].Class))
			{
				// dup!
				if (index >= 0)
				{
					Stock.Remove(index, 1);
					if (FrontIndex == Stock.Length)
						FrontIndex = 0;
				}
				item.Destroy();
				item = None;
				return;
			}
		}

		if (item != None)
		{
			ammo = RootController.spawn(ItemClass);
			if (ammo != None)
			{
				ammo.price = 1;
				prices = Listener.Intermission.AmmoPrices;

				inventory = RootController.Pawn.Inventory;
				while (inventory != None)
				{
					if (ClassIsChildOf(inventory.Class, ItemClass) && ClassIsChildOf(ItemClass, inventory.Class))
					{
						if (Ammunition(inventory).AmmoAmount >= Ammunition(inventory).MaxAmmo)
						{
							item.Destroy();
							item = None;
							return;
						}

						ammo.UnitsPerPurchase = Ammunition(inventory).PickupAmmo;
						break;
					}

					inventory = inventory.Inventory;
				}

				if (inventory == None)
				{
					AmmoClass = class<Ammunition>(DynamicLoadObject(item.AmmoName, class'Class'));
					if (AmmoClass != None)
						ammo.UnitsPerPurchase = AmmoClass.Default.PickupAmmo;
				}

				for (i=0;i<prices.Length;i++)
				{
					s = prices[i];
					if (InStr(s, item.AmmoName $ ",") == 0)
					{
						ammo.price = int(Mid(s, InStr(s,",") + 1));
						ammo.KioskData = prices[i];
						break;
					}
				}
				
				if (index >= 0)
					Stock[index] = ammo;
				item.Destroy();
				item = ammo;
			}
		}
	}
	else
	{
		if (index >= 0)
			Stock[index] = ammo;
		item.Destroy();
		item = None;
	}
}

function Purchase()
{
	local B9_HoloItem item;
	local int i;
	local bool wasWeapon;

	// generate a pickup and drop in pile at PickupDropTagName

	item = Stock[FrontIndex];
	wasWeapon = item.IsWeapon;

	B9_PlayerPawn(RootController.Pawn).HQBuyItem(item.InventoryName, item.price, PickupDropTagName);

	// if weapon, convert to ammo or delete
	if (Len(item.AmmoName) != 0)
	{
		ConvertToAmmo(FrontIndex, item);
	}
	else if (!item.CanAggregate)
	{
		// remove non-aggregate item
		Stock.Remove(FrontIndex, 1);
		item.Destroy();
		item = None;
		if (FrontIndex == Stock.Length)
			FrontIndex = 0;
	}

	if ( fIsWeaponKiosk && wasWeapon )
	{
		WeaponCount++;
		if (MaxWeapons <= WeaponCount)
		{
			// remove all weapons from kiosk
			for (i=0;i<Stock.Length;i++)
			{
				if (Stock[i].IsWeapon)
				{
					item = Stock[i];
					if (Len(item.AmmoName) != 0)
						ConvertToAmmo(i, item);
					if (item == None)
						--i;
				}
			}
		}
	}

/*
	if (Stock.Length == 0)
	{
		// Exit kiosk if all item in this catagory sold.
		MenuExit();
	}
	else
	{
*/
		for (i=0;i<Stock.Length;i++)
			SetItemPositioning(FrontIndex);
		StockStatus();
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

		if (result == 0) // buy it!
		{
			Purchase();
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
			//if (!bOverPurchase) ChangeSelection(MouseY < 320);
		}
	}
	else if( Action == IST_Release && (Key == IK_Enter || Key == IK_Space ||
		Key == IK_LeftMouse || Key == IK_Joy1) )
	{
		if (fKeyDown == IK_LeftMouse)
		{
			//if (bOverPurchase)
			//{
			if (bCanBuy)
			{
				RootController.PlaySound( fClickSound );
				// ConfirmPurchase(); // !!!! enable later
				Purchase(); // !!!! for now
			}
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
	fConvertToAmmo=true
	fStrPurchase="Purchase"
	fStrInsufficentFunds="Insufficent Funds"
	fStrUnavailable="Unavailable"
	fStrConfirmMsg="Are you sure you want to purchase this item?"
	fStrRestrictedMsg="Your security clearance to purchase this item is pending."
	fStrTooWeakMsg="You have insufficent strength to use this item."
	fStrCost="Cost:"
	fStrNothingToBuy="Out of stock! Please check back later."
	fMultiFrameTop=Texture'B9Menu_textures.Half_Size_Panes.multi_frame_top'
	fMultiFrameMiddle=Texture'B9Menu_textures.Half_Size_Panes.multi_frame_middle'
	fMultiFrameBottom=TexScaler'B9Menu_textures.Half_Size_Panes.multi_frame_bottom'
	fMultiFrameSubtitle=Texture'B9Menu_textures.Half_Size_Panes.multi_frame_subtitle'
	fSingleLineFrame=Texture'B9Menu_textures.Half_Size_Panes.single_line_frame'
	fKioskInfoLeft=Texture'B9MenuHelp_Textures.Choices.kiosk_info_1_left'
	fKioskInfoRight=Texture'B9MenuHelp_Textures.Choices.kiosk_info_1_right_buy'
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