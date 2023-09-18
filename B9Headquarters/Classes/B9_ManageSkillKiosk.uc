/////////////////////////////////////////////////////////////
// B9_ManageSkillKiosk
//

class B9_ManageSkillKiosk extends B9_BaseKiosk;

#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX
#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures
#exec OBJ LOAD FILE=..\textures\B9MenuHelp_Textures.utx PACKAGE=B9MenuHelp_Textures

var int fHulaColor;

var private bool bOverPurchase;
var private bool bCanBuy;
var private bool bUnavailable;

var localized string fStrPurchase;
var localized string fStrInsufficentFunds;
var localized string fStrUnavailable;

var localized string fStrConfirmMsg;
var localized string fStrRestrictedMsg;
var localized string fStrUpgrade;
var localized string fStrCost;

var localized string fStrCategoryName;
var localized string fStrNothingToBuy;
var localized string fStrSkillValue;
var localized string fStrPending;
var localized string fStrPoints;

var vector LastLocation;
var rotator LastRotation;

var array<B9_HoloItem> Stock;
var int FrontIndex;
var int NumSkills;
var bool bCache;

var B9_PageBrowser DescriptionView;
var array<string> DescriptionBody;

var float fSelectAnimTicks;
var bool fSelectReverse;
var float fEffectAnimTicks;

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

	if (fEffectAnimTicks > 0f)
	{
		fEffectAnimTicks -= Delta;
		if (fEffectAnimTicks <= 0f)
		{
			log("End");
			fEffectAnimTicks = 0f;
			RootController.BehindView(false);
			if (fFOV != 0f)
				RootController.SetFOV(fFOV);
			// !!!! turn off animation around player

			RootController.SetRotation(TriggerRot);
			RootController.Pawn.SetRotation(TriggerRot);
			for (i=0;i<Stock.Length;i++)
				SetItemPositioning(i);
		}
	}

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
		ZAxis * y - Listener.KioskHoloShift * YAxis;
	loc.Z += pawn.Eyeheight;
	item.SetLocation( loc );
	item.SetRotation( TriggerRot );
}

function StockStatus()
{
	local B9_HoloItem item;
	local Class TheClass;

	if (Stock.Length > 0)
	{
		item = Stock[FrontIndex];
		if (item.Bought && item.RealItem == None)
		{
			item.RealItem = 
				RootController.Pawn.FindInventoryType( class(DynamicLoadObject(item.InventoryName, class'Class')) );
		}

		bUnavailable = (item.Restricted ||
			item.RequiredStrength > B9_PlayerPawn(RootController.Pawn).fCharacterStrength);
		bCanBuy = (!bUnavailable && B9_PlayerPawn(RootController.Pawn).fCharacterSkillPoints >= item.Price);

		if (item.Bought)
		{
			if (item.RealItem != None)
				DescriptionBody[0] = "<center><font color=\"cyan\">" $ fStrSkillValue $
					string(B9_Skill(item.RealItem).FinalSkillStrength()) $ "</font></center><br/>";
			else
				DescriptionBody[0] = "<center><font color=\"cyan\">" $fStrSkillValue $fStrPending $ "</font></center><br/>";
			DescriptionBody[1] = item.Description;
		}
		else
		{
			DescriptionBody[0] = item.Description;
			if (item.Restricted)
				DescriptionBody[1] = fStrRestrictedMsg;
			else
				DescriptionBody[1] = "";
		}
		bCache = true;
	}
}

function int CountSkills(Inventory Inv)
{
	local int n;

	while (Inv != None)
	{
		if (B9_Skill(Inv) != None) n++;
		Inv = Inv.Inventory;
	}

	return n;
}

function StockMods(array<string> items)
{
	local int i, j, n;
	local B9_HoloItem item;
	local class<B9_HoloItem> ItemClass;
	local string cname;
	local int price;
	local Pawn pawn;
	local Class TheClass;
	local bool restricted;
	local string itemStr;

	pawn = RootController.Pawn;
	LastLocation = pawn.Location;
	LastRotation = pawn.Rotation;
	fSelectAnimTicks = 0.0001;

	NumSkills = CountSkills(pawn.Inventory);
	price = NumSkills;
	if (price < 5) price = 5;

	// items[i] is encoded: class,price

	Stock.Length = items.Length;

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
			//price = 1;
		}
		else
		{
			cname = Left(itemStr, n);
			//price = int(Mid(itemStr, n + 1));
		}

		ItemClass = class<B9_HoloItem>(DynamicLoadObject(cname $ "_Holo", class'Class'));

		if (ItemClass != None)
		{
			item = RootController.spawn(ItemClass);
			if (item != None)
			{
				item.Restricted = restricted;

				TheClass = class(DynamicLoadObject(cname, class'Class'));

				if (item.RemoveFromStock(pawn, TheClass, Listener))
				{
					item.Destroy();
					item = None;
					continue;
				}

				// Does player already have this mod?
				item.RealItem = pawn.FindInventoryType( TheClass );
				if (item.RealItem != None)
				{
					item.Bought = true;
					item.Price = 1;
				}
				else
				{
					item.Price = price;
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
	local color white, cyan, red;
	local color textColor, shadowColor, btnColor;
	local font oldFont;
	local int i, n;
	local B9_HoloItem item;
	local B9_HoloItem frontItem;
	local vector loc;
	local bool ClearZ;
	local float oldOrgX, oldOrgY;
	local float oldClipX, oldClipY;
	local string msg;
	local int x, y;
	local float sx, sy;

	if (fEffectAnimTicks > 0f)
		return;

	oldFont = Canvas.Font;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	cyan.R = 0;
	cyan.G = 255;
	cyan.B = 255;

	red.R = 255;
	red.G = 0;
	red.B = 0;

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

		DescriptionView.RenderPage( Canvas, DescriptionBody, 512, bCache );
		bCache = false;

		Canvas.SetOrigin(oldOrgX, oldOrgY); 
		Canvas.SetClip(oldClipX, oldClipY); 

		y += 42;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fSingleLineFrame, 256, 32, 0, 0, 256, 32 );

		n = B9_PlayerPawn(RootController.Pawn).fCharacterSkillPoints;
		if (n >= item.Price)
			Canvas.SetDrawColor(white.R, white.G, white.B);
		else
			Canvas.SetDrawColor(red.R, red.G, red.B);

		Canvas.SetPos( x + 10, y + 8);
		if (item.Bought)
			Canvas.DrawText(fStrUpgrade $ string(item.Price));
		else
			Canvas.DrawText(fStrCost $ string(item.Price));

		msg = fStrPoints $ string(B9_PlayerPawn(RootController.Pawn).fCharacterSkillPoints);
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

	//Canvas.Font = fMyFont16;
	//Canvas.Style = RootController.ERenderStyle.STY_Normal;
	//DrawTextWithShadow( Canvas,
	//	"$" $ string(B9_PlayerPawn(RootController.Pawn).fCharacterCash),
	//	20, 20, white, shadowColor, 2 );

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

function AddSkill(B9_PlayerPawn Pawn, B9_HoloItem Item)
{
	Pawn.HQAddSkill(Item.InventoryName);
}

function ModifySkill(B9_PlayerPawn Pawn, B9_HoloItem Item)
{
	Pawn.HQModifySkill(Item.InventoryName, Item.Price);
}

/*
function AddBodyModCalibration(B9_PlayerPawn Pawn, B9_HoloItem Item)
{
	local B9_BodyModCalibration cal;

	// add locally
	cal = new(None) class'B9_BodyModCalibration';
	cal.SetCalibration(Pawn.Name, Item);
	Listener.AddCalibration(cal);

	if (Pawn.Role < ROLE_Authority)
		Pawn.HQAddBodyModCalibration(Item.InventoryName, Item.Price);
	else
		Pawn.fCharacterCash -= Item.Price;
}
*/

function Purchase()
{
	local Actor A, B;
	local float dist, Bdist;
	local B9_HoloItem item;
	local class TheClass;
	local int i;
	local B9_PlayerPawn pp;
	local int price;
	local vector StartLocation;

	pp = B9_PlayerPawn(RootController.Pawn);

	if (Stock[FrontIndex].Bought)
	{
		ModifySkill(pp, Stock[FrontIndex]);
	}
	else
	{
		AddSkill(pp, Stock[FrontIndex]);
		Stock[FrontIndex].Bought = true;
		NumSkills++;
	}

	price = NumSkills;
	if (price < 5) price = 5;

	for (i=0;i<Stock.Length;i++)
	{
		item = Stock[i];
		TheClass = class(DynamicLoadObject(item.InventoryName, class'Class'));
		if (item.RemoveFromStock(pp, TheClass, Listener))
		{
			Stock.Remove(i, 1);
			--i;
		}
		else
		{
			if (item.Bought)
				item.Price = 1;
			else
				item.Price = price;
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
		if (FrontIndex >= Stock.Length)
			FrontIndex = 0;

		for (i=0;i<Stock.Length;i++)
			SetItemPositioning(i);
	
		StockStatus();
/*
	}
*/

	fEffectAnimTicks = 4.0f;
	RootController.BehindView(true);
	if (fFOV != 0f)
		RootController.ResetFOV();
	log("Creating BodyMod");
	StartLocation = RootController.Pawn.Location;
	StartLocation.Z = StartLocation.Z - 50.0;

	if( fHulaColor == 1 )
	{
		RootController.Pawn.Spawn( class'WeaponBodyMod', RootController.Pawn,, StartLocation, RootController.Pawn.Rotation );
	}else if ( fHulaColor == 2 )
	{
		RootController.Pawn.Spawn( class'MiscBodyMod', RootController.Pawn,, StartLocation, RootController.Pawn.Rotation );
	}else if ( fHulaColor == 0 )
	{
		RootController.Pawn.Spawn( class'SkillBodyMod', RootController.Pawn,, StartLocation, RootController.Pawn.Rotation );
	}
	
	

	
	// !!!! turn on animation around player
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

	if (Super.KeyEvent( Key, Action, Delta ) || bIgnoreEvent || fEffectAnimTicks > 0f || ChildInteraction != None)
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
				// ConfirmPurchase(); // enable later
				Purchase(); // for now
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
		if (fKeyDown == IK_None && Stock.Length > 1)
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
		if (fKeyDown == IK_None && Stock.Length > 1)
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
	fStrPurchase="Purchase"
	fStrInsufficentFunds="Insufficent Funds"
	fStrUnavailable="Unavailable"
	fStrConfirmMsg="Are you sure you want to purchase this modifcation?"
	fStrRestrictedMsg="Your security clearance to purchase this modification is pending."
	fStrUpgrade="Upgrade Cost: "
	fStrCost="Install Cost: "
	fStrNothingToBuy="Out of stock! Please check back later."
	fStrSkillValue="Skill Value: "
	fStrPending="Pending"
	fStrPoints="Points: "
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