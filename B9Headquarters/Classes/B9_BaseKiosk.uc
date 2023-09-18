/////////////////////////////////////////////////////////////
// B9_BaseKiosk
//

class B9_BaseKiosk extends B9_MenuInteraction;

var name TriggerTagName;

var(Kiosk) float fBackOffPawn;
var(Kiosk) float fFOV;

var sound fUpSound;
var sound fDownSound;
var sound fClickSound;
var sound fCancelSound;

var EInputKey fKeyDown;

var bool bHUDWasInView;
var bool bOriginInited;
var bool bIgnoreEvent;

var float oldOrgX, oldOrgY;
var float oldClipX, oldClipY;

var B9_HQListener Listener;
var rotator TriggerRot;

var font fMyFont24;
var font fMyFont20;
var font fMyFont16;

var class<B9_PageBrowser> BrowserClass;

//var() localized string MSA24Font;
//var() localized string MSA20Font;
//var() localized string MSA16Font;
var localized font MSA24Font;
var localized font MSA20Font;
var localized font MSA16Font;


function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	local B9_PlayerController pc;
	local vector loc, X, Y, Z;
	local string feh, sname;
	local int pos;
	local MenuUtility utils;

	//Log("B9_BaseKiosk.MenuInit");

	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
		ActivateMouse();

		utils = new(None) class'MenuUtility';
		utils.ResetInput(RootController);
		utils.DirectAxisEnable(RootController, false);
		
		fMyFont24 = MSA24Font;
		fMyFont20 = MSA20Font;
		fMyFont16 = MSA16Font;

		pc = B9_PlayerController(controller);
		if (pc != None)
		{
			if (B9_HUD(pc.myHUD) != None && B9_HUD(pc.myHUD).fHideHUD == false)
				bHUDWasInView = true; 
			if (bHudWasInView)
				B9_HUD(pc.myHUD).ToggleHUD();

			//Log("B9_BaseKiosk before find listener");

			ForEach pc.AllActors(class'B9_HQListener', Listener)
			{
				if (Listener.Intermission == None)
				{
//					Listener.FindIntermission(pc.Pawn);
					sname = ""$Listener.IntermissionName;
					feh = ""$Listener;
					pos = InStr(feh, ".");
					if (pos != -1)
						sname = Left(feh,pos+1)$sname;
					Listener.intermission = B9_Intermission(DynamicLoadObject( sname, class'B9_Intermission' ));
				}

				//Log("B9_BaseKiosk Listener="$Listener$" Intermission="$Listener.Intermission);

				break;
			}
		}
	}
}

function SetGenericRotator(int id, rotator r)
{
	TriggerRot = r;
}

function string ServerTriggerTagName(name TriggerTag)
{
	return "" $ TriggerTagName;
}

/*
function string GetTriggerTagName()
{
	return "" $ TriggerTagName;
}

function TriggerSideEffects()
{
	local Triggers T;
	local string ttn, tn;

	ttn = GetTriggerTagName();

	ForEach RootController.AllActors(class'Triggers', T)
	{
		tn = "" $ T.Tag;
		if (tn == ttn)
			T.Trigger(Listener, RootController.Pawn);
	}
}
*/

function MenuExit()
{
	local B9_PlayerController pc;
	local MenuUtility utils;
	local int i;

	pc = B9_PlayerController(RootController);

	ViewportOwner.bShowWindowsMouse = false;
	PopInteraction(pc, pc.Player);
	
	if (bHudWasInView)
		B9_HUD(pc.myHUD).fHideHUD = false;

	utils = new(None) class'MenuUtility';
	utils.DirectAxisEnable(RootController, true);

	pc.ExitKioskMode();
}

function RenderDisplay( canvas Canvas )
{
	// abstract
}

function PostRender( canvas Canvas )
{
	if (!bOriginInited)
	{
		RootInteraction.SetOrigin((Canvas.ClipX - 640) / 2, (Canvas.ClipY - 480) / 2);
		bOriginInited = true;
	}

	oldOrgX = Canvas.OrgX;
	oldOrgY = Canvas.OrgY;
	oldClipX = Canvas.ClipX;
	oldClipY = Canvas.ClipY;

	Canvas.SetOrigin(RootInteraction.OriginX, RootInteraction.OriginY); 

	RenderDisplay( Canvas );

	Super.PostRender( Canvas );

	Canvas.SetOrigin(oldOrgX, oldOrgY); 
	Canvas.SetClip(oldClipX, oldClipY); 

	MouseRender( Canvas );
}

defaultproperties
{
	BrowserClass=Class'B9_PageBrowser'
	MSA24Font=Font'B9_Fonts.MicroscanA24'
	MSA20Font=Font'B9_Fonts.MicroscanA20'
	MSA16Font=Font'B9_Fonts.MicroscanA16'
}