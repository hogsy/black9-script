class UDebugMenuBar extends UWindowMenuBar;

//////////////////////////////////////////
// X. Tan, Taldren, 5/27/03
// Localization
var() localized string GameMenu;
var() localized string LoadNewMapMenu;
var() localized string ConnectToMenu;
var() localized string ScreenShotMenu;
var() localized string FlushMenu;
var() localized string ExitMenu;

var() localized string RenderModeMenu;
var() localized string WireframeMenu;
var() localized string ZonesMenu;
var() localized string FlatShadedBSPMenu;
var() localized string BSPSplitsMemu;
var() localized string RegularMenu;
var() localized string UnlitMenu;
var() localized string LightingOnlyMenu;
var() localized string DepthComplexityMenu;
var() localized string TopDownMenu;
var() localized string FrontMenu;
var() localized string SideMenu;

var() localized string RenderCmdMenu;
var() localized string BlendMenu;
var() localized string BoneMenu;
var() localized string SkinMenu;

var() localized string StatsMenu;
var() localized string AllStatsMenu;
var() localized string NoStatsMenu;
var() localized string RenderStatsMenu;
var() localized string GameStatsMenu;
var() localized string HardwareStatsMenu;
var() localized string NetStatsMenu;
var() localized string AnimStatsMenu;

var() localized string ShowCmdMenu;
var() localized string ShowActorMenu;
var() localized string ShowStaticMeshMenu;
var() localized string ShowTerrainMenu;
var() localized string ShowFogenu;
var() localized string ShowSkyMenu;
var() localized string ShowCoronasMenu;
var() localized string ShowParticlesMenu;

var() localized string OptionsMenu;
var() localized string VideoMenu;
//var() localized string AudioMenu;
//var() localized string KeysMenu;

var() localized string KarmaPhysicsMeu;
var() localized string CollisionMeu;
var() localized string ContactsMeu;
var() localized string TrianglesMeu;
var() localized string ComMeu;
var() localized string KStopMeu;
var() localized string KStepMeu;

var() localized string DebugVersionLabel;

var() localized string ToggleFullScrnCmd;

var() localized string ShotCmd;
var() localized string FlushCmd;
var() localized string QuitCmd;

var() localized string RModeCmd;
var() localized string RenBlendCmd;
var() localized string RenBoneCmd;
var() localized string RenSkinCmd;

var() localized string StatAllCmd;
var() localized string StatNoneCmd;
var() localized string StatRenderCmd;     
var() localized string StatGameCmd;     
var() localized string StatHardwareCmd;     
var() localized string StatNetCmd;     
var() localized string StatAnimCmd;

var() localized string ShowActorsCmd;  
var() localized string ShowStaticMeshesCmd;  
var() localized string ShowTerrainCmd;  
var() localized string ShowFogCmd;
var() localized string ShowSkyCmd;
var() localized string ShowCoronasCmd;
var() localized string ShowParticlesCmd;

var() localized string KdrawCollisionCmd;
var() localized string KdrawContactsCmd; 
var() localized string KdrawTrianglesCmd; 
var() localized string KdrawComCmd; 
var() localized string KdrawKStopCmd; 
var() localized string KdrawKStepCmd;
// End Modification
/////////////////////////

var UWindowPulldownMenu Game, RModes, Rend, KDraw, Stats, Show, Player, Options;
var UWindowMenuBarItem GameItem, RModesItem, RendItem, KDrawItem, StatsItem, ShowItem, PlayerItem, OptionsItem;
var bool bShowMenu;

function Created()
{
	Super.Created();
	
	GameItem = AddItem(GameMenu);
	Game = GameItem.CreateMenu(class 'UWindowPulldownMenu');
	Game.MyMenuBar = self;
	Game.AddMenuItem(LoadNewMapMenu,none);
	Game.AddMenuItem("-",none);
	Game.AddMenuItem(ConnectToMenu,none);
	Game.AddMenuItem("-",none);
	Game.AddMenuItem(ScreenShotMenu,none);
	Game.AddMenuItem(FlushMenu,none);
	Game.AddMenuItem("Test GUI",none);
	Game.AddMenuItem("-",none);
	Game.AddMenuItem(ExitMenu,none);

	RModesItem = AddItem(RenderModeMenu);
	RModes = RModesItem.CreateMenu(class 'UWindowPulldownMenu');
	RModes.MyMenuBar = self;
	RModes.AddMenuItem(WireframeMenu,none);
	RModes.AddMenuItem(ZonesMenu,none);
	RModes.AddMenuItem(FlatShadedBSPMenu,none);
	RModes.AddMenuItem(BSPSplitsMemu,none);
	RModes.AddMenuItem(RegularMenu,none);
	RModes.AddMenuItem(UnlitMenu,none);
	RModes.AddMenuItem(LightingOnlyMenu,none);
	RModes.AddMenuItem(DepthComplexityMenu,none);
	RModes.AddMenuItem("-",None);
	RModes.AddMenuItem(TopDownMenu,None);
	RModes.AddMenuItem(FrontMenu,None);
	RModes.AddMenuItem(SideMenu,None);

	RendItem = AddItem(RenderCmdMenu);
	Rend = RendItem.CreateMenu(class 'UWindowPulldownMenu');
	Rend.MyMenuBar = self;
	Rend.AddMenuItem(BlendMenu,none);
	Rend.AddMenuItem(BoneMenu,none);
	Rend.AddMenuItem(SkinMenu,none);

	StatsItem = AddItem(StatsMenu);
	Stats = StatsItem.CreateMenu(class 'UWindowPulldownMenu');
	Stats.MyMenuBar = self;
	Stats.AddMenuItem(AllStatsMenu,None);
	Stats.AddMenuItem(NoStatsMenu,None);
	Stats.AddMenuItem("-",None);
	Stats.AddMenuItem(RenderStatsMenu,None);
	Stats.AddMenuItem(GameStatsMenu,None);
	Stats.AddMenuItem(HardwareStatsMenu, None);
	Stats.AddMenuItem(NetStatsMenu,None);
	Stats.AddMenuItem(AnimStatsMenu,None);

	ShowItem = AddItem(ShowCmdMenu);
	Show = ShowItem.CreateMenu(class 'UWindowPulldownMenu');
	Show.MyMenuBar = self;
	Show.AddMenuItem(ShowActorMenu,None);
	Show.AddMenuItem(ShowStaticMeshMenu,None);
	Show.AddMenuItem(ShowTerrainMenu,None);
	Show.AddMenuItem(ShowFogenu,None);
	Show.AddMenuItem(ShowSkyMenu,None);
	Show.AddMenuItem(ShowCoronasMenu,None);
	Show.AddMenuItem(ShowParticlesMenu,None);
			
	OptionsItem = AddItem(OptionsMenu);
	Options = OptionsItem.CreateMenu(class 'UWindowPulldownMenu');
	Options.MyMenuBar = self;
	Options.AddMenuItem(VideoMenu,None);
//	Options.AddMenuItem(AudioMenu,None);
//	Options.AddMenuItem(KeysMenu,None);

	KDrawItem = AddItem(KarmaPhysicsMeu);
	KDraw = KDrawItem.CreateMenu(class 'UWindowPulldownMenu');
	KDraw.MyMenuBar = self;
	KDraw.AddMenuItem(CollisionMeu,none);
	KDraw.AddMenuItem(ContactsMeu,none);
	KDraw.AddMenuItem(TrianglesMeu,none);
	KDraw.AddMenuItem(ComMeu,none);
	KDraw.AddMenuItem("-",none);
	KDraw.AddMenuItem(KStopMeu,none);
	KDraw.AddMenuItem(KStepMeu,none);

	bShowMenu = true;
	Spacing = 12;
	
}

function SetHelp(string NewHelpText)
{
}

function ShowHelpItem(UWindowMenuBarItem I)
{
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	C.SetDrawColor(255,255,255);	
	if(UWindowMenuBarItem(Item).bHelp) W = W - 16;

	UWindowMenuBarItem(Item).ItemLeft = X;
	UWindowMenuBarItem(Item).ItemWidth = W;
	LookAndFeel.Menu_DrawMenuBarItem(Self, UWindowMenuBarItem(Item), X, Y, W, H, C);
}

function DrawMenuBar(Canvas C)
{
	local float W, H;
	local string VersionText;
	VersionText = DebugVersionLabel@GetLevel().EngineVersion;
	LookAndFeel.Menu_DrawMenuBar(Self, C);

	C.Font = Root.Fonts[F_Normal];

	C.SetDrawColor(0,0,0);

	TextSize(C, VersionText, W, H);
	ClipText(C, WinWidth - W - 20, 3, VersionText);
}

function LMouseDown(float X, float Y)
{
	if(X > WinWidth - 13) GetPlayerOwner().ConsoleCommand(ToggleFullScrnCmd);
	Super.LMouseDown(X, Y);
}
function NotifyQuitUnreal()
{
	local UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyQuitUnreal();
}

function NotifyBeforeLevelChange()
{
	local UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyBeforeLevelChange();
}

function NotifyAfterLevelChange()
{
	local UWindowMenuBarItem I;

	for(I = UWindowMenuBarItem(Items.Next); I != None; I = UWindowMenuBarItem(I.Next))
		if(I.Menu != None)
			I.Menu.NotifyAfterLevelChange();
}

function MenuCmd(int Menu, int Item)
{
	Super.MenuCmd(Menu, Item);
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	switch(Msg) 
	{
		case WM_KeyDown:
		
		
			if (Key==27) // GRR
			{
				if (Selected == None)
				{
					Root.GotoState('');
				}

				return;
			}
			break;
	}
	Super.WindowEvent(Msg, C, X, Y, Key);
	
}
	
function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, W, H;
	local UWindowMenuBarItem I;

	DrawMenuBar(C);

	for( I = UWindowMenuBarItem(Items.Next);I != None; I = UWindowMenuBarItem(I.Next) )
	{
		C.Font = Root.Fonts[F_Normal];
		TextSize( C, RemoveAmpersand(I.Caption), W, H );
	
		if(I.bHelp)
		{
			DrawItem(C, I, (WinWidth - (W + Spacing)), 1, W + Spacing, 14);
		}
		else
		{
			DrawItem(C, I, X, 1, W + Spacing, 14);
			X = X + W + Spacing;
		}		
	}
}

function MenuItemSelected(UWindowBase Sender, UWindowBase Item)
{
	local UWindowPulldownMenu Menu;
	local UWindowPulldownMenuItem I;
	
	Menu = UWindowPulldownMenu(Sender);
	I = UWindowPulldownMenuItem(Item);

	if (Menu!=None)
	{
		switch (Menu)
		{
			case Game:
				switch (I.Tag)
				{
					case 1 :
						// Open the Map Menu
						Root.ShowModal(Root.CreateWindow(class'UDebugMapListWindow', (Root.WinWidth/2)-200, (Root.WinHeight/2)-107, 400, 214, self));
						return;						
						break;
					
					case 3 :
						// Open the Map Menu
						Root.ShowModal(Root.CreateWindow(class'UDebugOpenWindow', (Root.WinWidth/2)-150,(Root.WinHeight/2)-45, 300,90, self));
						return;						
						break;
										
					case 5 : Root.ConsoleCommand(ShotCmd); break;
					case 6 : Root.ConsoleCommand(FlushCmd); break;
					case 7 :
						GetPlayerOwner().ClientOpenMenu("GUI.JoeTest");
						break;						
					case 9 : Root.ConsoleCommand(QuitCmd); break;
				}
				break;
			case RModes:
				if (I.Tag < 9)
					Root.ConsoleCommand(RModeCmd$I.Tag);
				else if (I.Tag >9)
					Root.ConsoleCommand(RModeCmd$I.Tag+3);
					
				break;
				
			case Rend:
				switch (I.Tag)
				{
					case 1 : Root.ConsoleCommand(RenBlendCmd); break;    
					case 2 : Root.ConsoleCommand(RenBoneCmd); break;    
					case 3 : Root.ConsoleCommand(RenSkinCmd); break;
				}
				break;
			
			case Stats:
				switch (I.Tag)
				{
 					case 1 : Root.ConsoleCommand(StatAllCmd);break;     
 					case 2 : Root.ConsoleCommand(StatNoneCmd);break;     
 					case 4 : Root.ConsoleCommand(StatRenderCmd);break;     
 					case 5 : Root.ConsoleCommand(StatGameCmd);break;     
 					case 6 : Root.ConsoleCommand(StatHardwareCmd);break;     
 					case 7 : Root.ConsoleCommand(StatNetCmd);break;     
 					case 8 : Root.ConsoleCommand(StatAnimCmd);break;
				}
				break;
				
			case Show:
				switch (I.Tag)
				{
 					case 1 : Root.ConsoleCommand(ShowActorsCmd); break;  
 					case 2 : Root.ConsoleCommand(ShowStaticMeshesCmd); break;  
 					case 3 : Root.ConsoleCommand(ShowTerrainCmd); break;  
 					case 4 : Root.ConsoleCommand(ShowFogCmd); break;  
 					case 5 : Root.ConsoleCommand(ShowSkyCmd); break;  
 					case 6 : Root.ConsoleCommand(ShowCoronasCmd); break;  
 					case 7 : Root.ConsoleCommand(ShowParticlesCmd); break;  
   				}
				break;
			
			case Options:
				switch (I.tag)
				{
					case 1 : // Video Menu
								
						Root.ShowModal(Root.CreateWindow(class'UDebugVideoWindow', Options.WinLeft, 20, 220, 100, self));
						return;						
						break;

					case 2 : break; // Audio Menu
					case 3 : break; // Input Menu
				}
				break;
				
			case KDraw:
				switch (I.tag)
				{
					case 1 : Root.ConsoleCommand("kdraw Collision"); break; 
					case 2 : Root.ConsoleCommand("kdraw Contacts"); break; 
					case 3 : Root.ConsoleCommand("kdraw Triangles"); break; 
					case 4 : Root.ConsoleCommand("kdraw Com"); break; 
					case 6 : Root.ConsoleCommand("kdraw KStop"); break; 
					case 7 : Root.ConsoleCommand("kdraw KStep"); break;
				}
				break; 
		}
	}
	Root.GotoState('');
 
}

defaultproperties
{
	GameMenu="&Game"
	LoadNewMapMenu="&Load New Map"
	ConnectToMenu="&Connect to.."
	ScreenShotMenu="ScreenShot"
	FlushMenu="Flush"
	ExitMenu="E&xit"
	RenderModeMenu="&Render Modes"
	WireframeMenu="&Wireframe"
	ZonesMenu="&Zones"
	FlatShadedBSPMenu="&Flat Shaded BSP"
	BSPSplitsMemu="&BSP Splits"
	RegularMenu="&Regular"
	UnlitMenu="&Unlit"
	LightingOnlyMenu="&Lighting Only"
	DepthComplexityMenu="&Depth Complexity"
	TopDownMenu="&Top Down"
	FrontMenu="&Front"
	SideMenu="&Side"
	RenderCmdMenu="Render &Commands"
	BlendMenu="&Blend"
	BoneMenu="&Bone"
	SkinMenu="&Skin"
	StatsMenu="&Stats"
	AllStatsMenu="&All"
	NoStatsMenu="&None"
	RenderStatsMenu="&Render"
	GameStatsMenu="&Game"
	HardwareStatsMenu="&Hardware"
	NetStatsMenu="Ne&t"
	AnimStatsMenu="Ani&m"
	ShowCmdMenu="Sho&w Commands"
	ShowActorMenu="Show &Actors"
	ShowStaticMeshMenu="Show Static &Meshes"
	ShowTerrainMenu="Show &Terrain"
	ShowFogenu="Show &Fog"
	ShowSkyMenu="Show &Sky"
	ShowCoronasMenu="Show &Coronas"
	ShowParticlesMenu="Show &Particles"
	OptionsMenu="&Options"
	VideoMenu="&Video"
	KarmaPhysicsMeu="&Karma Physics"
	CollisionMeu="&Collision"
	ContactsMeu="C&ontacts"
	TrianglesMeu="&Triangles"
	ComMeu="Co&m"
	KStopMeu="KStop"
	KStepMeu="KStep"
	DebugVersionLabel="[Debug Menu] Version "
	ToggleFullScrnCmd="togglefullscreen"
	ShotCmd="Shot"
	FlushCmd="Flush"
	QuitCmd="Quit"
	RModeCmd="RMode "
	RenBlendCmd="rend blend"
	RenBoneCmd="rend bone"
	RenSkinCmd="rend skin"
	StatAllCmd="stat All"
	StatNoneCmd="stat NONE"
	StatRenderCmd="stat RENDER"
	StatGameCmd="stat GAME"
	StatHardwareCmd="stat HARDWARE"
	StatNetCmd="stat NET"
	StatAnimCmd="stat ANIM"
	ShowActorsCmd="show Actors"
	ShowStaticMeshesCmd="show StaticMeshes"
	ShowTerrainCmd="show Terrain"
	ShowFogCmd="show Fog"
	ShowSkyCmd="show Sky"
	ShowCoronasCmd="show Coronas"
	ShowParticlesCmd="show Particles"
	KdrawCollisionCmd="kdraw Collision"
	KdrawContactsCmd="kdraw Contacts"
	KdrawTrianglesCmd="kdraw Triangles"
	KdrawComCmd="kdraw Com"
	KdrawKStopCmd="kdraw KStop"
	KdrawKStepCmd="kdraw KStep"
}