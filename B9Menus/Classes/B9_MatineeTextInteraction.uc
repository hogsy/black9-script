// B9_MatineeTextInteraction

class B9_MatineeTextInteraction extends B9_MenuInteraction;

//#exec OBJ LOAD FILE=..\sounds\B9SoundFX.uax PACKAGE=B9SoundFX
#exec OBJ LOAD FILE=..\textures\B9Menu_Textures.utx PACKAGE=B9Menu_Textures
#exec OBJ LOAD FILE=..\textures\B9MenuHelp_Textures.utx PACKAGE=B9MenuHelp_Textures

var font fMyFont16;
var bool bOriginInited;
var float oldOrgX, oldOrgY;
var float oldClipX, oldClipY;

//var sound fUpSound;
//var sound fDownSound;
//var sound fClickSound;
//var sound fCancelSound;

var texture fFullFrameTopLeft;
var texture fFullFrameTopRight;
var texture fFullFrameMiddleLeft;
var texture fFullFrameMiddleRight;
var texture fFullFrameBottomLeft;
var texture fFullFrameBottomRight;
var texture fMoreArrow;
var texture fYesNoLeft;
var texture fYesNoRight;

var string fNewline;

var B9_MatineeTextHolder Holder;
var float CinematicsRatio;
var string Message;
var string Answers[6];
var int AnswerCount;
var sound Voice;
var bool bAtTop;
var bool bLetterbox;
var bool bQuery;
var bool bHasMore;
var bool bInteractive;
var bool bYesNo;

var EInputKey fKeyDown;
var int fSelItem;

//var() localized string MSA16Font;
var localized font MSA16Font;

function Initialized()
{
	fMyFont16 = MSA16Font; //LoadFont( MSA16Font );
	fKeyDown = IK_None;
}

function MenuInit(B9_MenuInteraction interaction, PlayerController controller, B9_MenuInteraction parent)
{
	Super.MenuInit(interaction, controller, parent);

	if (RootInteraction == self)
	{
		ActivateMouse();
	}
}

function SetHolder(B9_MatineeTextHolder h)
{
	local int i;

	Holder = h;
	i = Holder.TextIndex;
	Message = Holder.MatineeText[i].Text;
	AnswerCount = 0;

	bQuery = (Holder.MatineeText[i].Speaker == Holder.DialogueSpeaker.DS_NPC_QUERY);
	bYesNo = (Holder.MatineeText[i].Speaker == Holder.DialogueSpeaker.DS_YESNO);
	bAtTop = (bYesNo || Holder.MatineeText[i].Speaker == Holder.DialogueSpeaker.DS_NPC ||
			  Holder.MatineeText[i].Speaker == Holder.DialogueSpeaker.DS_NPC_MORE ||
			  Holder.MatineeText[i].Speaker == Holder.DialogueSpeaker.DS_NPC_DONE);
	bHasMore = (Holder.MatineeText[i].Speaker == Holder.DialogueSpeaker.DS_NPC_MORE ||
				Holder.MatineeText[i].Speaker == Holder.DialogueSpeaker.DS_PC_MORE);
	bInteractive = (bHasMore || bQuery || bYesNo ||
					Holder.MatineeText[i].Speaker == Holder.DialogueSpeaker.DS_NPC_DONE ||
					Holder.MatineeText[i].Speaker == Holder.DialogueSpeaker.DS_PC_DONE);
	bLetterbox = Holder.MatineeText[i].Speaker == Holder.DialogueSpeaker.DS_LETTERBOX;

	Holder.ReplaceText(Message, "<br>", fNewline);

	Voice = Holder.MatineeText[i].Voice;
	if (Voice != None)
	{
		if (Holder.fPlayerPawn != None)
			Holder.fPlayerPawn.PlaySound(Voice, SLOT_Talk);
		else
			RootController.PlaySound(Voice, SLOT_Talk);
	}

	if (bQuery)
	{
		while (Holder.MatineeText[++i].Speaker == Holder.DialogueSpeaker.DS_PC_CHOICE)
		{
			Answers[AnswerCount++] = Holder.MatineeText[i].Text;
		}
	}
}

function CloseDialogue()
{
	if (Holder != None)
	{
		ViewportOwner.bShowWindowsMouse = false;
		Holder = None;
	}
}

function DrawBorder( canvas Canvas, int need, out int y)
{
	local int i, x;

	x = 320 - 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameTopRight, 256, 32, 0, 0, 256, 32 );

	for (i=0;i<need;i++)
	{
		x = 320 - 256;
		y += 32;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fFullFrameMiddleLeft, 256, 32, 0, 0, 256, 32 );

		x += 256;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fFullFrameMiddleRight, 256, 32, 0, 0, 256, 32 );
	}

	x = 320 - 256;
	y += 32;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameBottomLeft, 256, 32, 0, 0, 256, 32 );

	x += 256;
	Canvas.SetPos( x, y );
	Canvas.DrawTile( fFullFrameBottomRight, 256, 32, 0, 0, 256, 32 );
}

function PostRender( canvas Canvas )
{
	local color white, orange;
	local int x, y;
	local int i;
	local float sx, sy, ty;
	local int need;
	local int ybase;
	local int orgx, orgy;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	orange.R = 255;
	orange.G = 165;
	orange.B = 0;

	if (!bOriginInited)
	{
		if (bLetterbox)
			RootInteraction.SetOrigin(Canvas.OrgX, Canvas.OrgY);
		else
			RootInteraction.SetOrigin((Canvas.ClipX - 640) / 2, (Canvas.ClipY - 480) / 2);
		bOriginInited = true;
	}

	oldOrgX = Canvas.OrgX;
	oldOrgY = Canvas.OrgY;
	oldClipX = Canvas.ClipX;
	oldClipY = Canvas.ClipY;

	Canvas.SetOrigin(RootInteraction.OriginX, RootInteraction.OriginY); 

	Canvas.SetDrawColor(white.R, white.G, white.B);
	Canvas.Style = RootController.ERenderStyle.STY_Normal;

/*
	if (fChoicesRight != None)
	{
		x = 320 - 256;
		y = 480 - 52;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fChoicesLeft, 256, 32, 0, 0, 256, 32 );

		x += 256;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fChoicesRight, 256, 32, 0, 0, 256, 32 );
	}
	else
	{
		x = 320 - 128;
		y = 480 - 52;
		Canvas.SetPos( x, y );
		Canvas.DrawTile( fChoicesLeft, 256, 32, 0, 0, 256, 32 );
	}
*/

	Canvas.Font = fMyFont16;

	// 96 is minimum border height, lets say 64 for text height (16 pixel border)

	if (bLetterbox)
	{
		ybase = 16.0f + (oldClipY + oldClipY / CinematicsRatio) / 2.0f;

		x = oldClipX / 2 - 256;
		y = ybase;
		Canvas.SetOrigin(RootInteraction.OriginX + x, RootInteraction.OriginY + y); 
		Canvas.SetClip(512, 480); 
		Canvas.bCenter = true;
	}
	else
	{
		Canvas.SetClip(512 - 64, 480); 
		Canvas.StrLen(Message, sx, sy);
		Canvas.SetClip(oldClipX, oldClipY);

		need = (int(sy) + 31) / 32 - 1;
		if (need <= 0) need = 1;

		if (bAtTop || bQuery)
		{
			ybase = 20;
		}
		else
		{
			ybase = 480 - 84 - 32 * need;
		}

		y = ybase;
		DrawBorder(Canvas, need, y);

		if (bHasMore)
		{
			x = 320 + 256 - 26;
			y += 6;
			Canvas.SetPos( x, y );
			Canvas.DrawTile( fMoreArrow, 16, 16, 0, 0, 16, 16 );
		}

		if (bYesNo)
		{
			x = 320 - 256;
			y = 480 - 52;
			Canvas.SetPos( x, y );
			Canvas.DrawTile( fYesNoLeft, 256, 32, 0, 0, 256, 32 );

			x += 256;
			Canvas.SetPos( x, y );
			Canvas.DrawTile( fYesNoRight, 256, 32, 0, 0, 256, 32 );
		}

		x = 320 - 256;
		y = ybase;
		Canvas.SetOrigin(RootInteraction.OriginX + x + 32, 
			RootInteraction.OriginY + y + 32 + 16 * need - sy / 2); 
		Canvas.SetClip(512 - 64, 480); 
	}

	Canvas.SetPos(0, 0);
	Canvas.DrawText(Message);
	Canvas.bCenter = false;

	if (bQuery)
	{
		Canvas.SetClip(oldClipX, oldClipY);
		Canvas.SetOrigin(RootInteraction.OriginX, RootInteraction.OriginY); 
		
		ty = 0.0f;
		Canvas.SetClip(512 - 64, 480); 
		for (i=0;i<answerCount;i++)
		{
			if (i > 0) ty += 10.0f;
			Canvas.StrLen(Answers[i], sx, sy);
			ty += sy;
		}
		Canvas.SetClip(oldClipX, oldClipY);

		need = (int(ty) + 31) / 32 - 1;
		if (need <= 0) need = 1;

		ybase = 480 - 84 - 32 * need;

		y = ybase;
		DrawBorder(Canvas, need, y);

		x = 320 - 256;
		y = ybase;
		orgx = RootInteraction.OriginX + x + 32;
		orgy = RootInteraction.OriginY + y + 32 + 16 * need - ty / 2;
		Canvas.SetOrigin(orgx, orgy);
		Canvas.SetClip(512 - 64, 480); 

		ty = 0.0f;
		for (i=0;i<answerCount;i++)
		{
			if (i > 0) ty += 10.0f;
			Canvas.StrLen(Answers[i], sx, sy);

			Canvas.SetDrawColor(white.R, white.G, white.B);

			if (fSelItem == i)
			{
				Canvas.SetOrigin(orgx - 24, orgy);
				Canvas.SetPos( 0, ty + sy / 2 - 8);
				Canvas.DrawTile( fMoreArrow, 16, 16, 0, 0, 16, 16 );
				Canvas.SetOrigin(orgx, orgy);

				Canvas.SetDrawColor(orange.R, orange.G, orange.B);
			}

			Canvas.SetPos(0, ty);
			Canvas.DrawText(Answers[i]);

			ty += sy;
		}
	}

	Canvas.SetOrigin(oldOrgX, oldOrgY); 
	Canvas.SetClip(oldClipX, oldClipY); 

	MouseRender( Canvas );
}

function ChangeSelection(int delta)
{
	fSelItem = (fSelItem + AnswerCount + delta) % AnswerCount;
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	if (Super.KeyEvent( Key, Action, Delta ))
		return true;

	if( Action == IST_Press && Key == IK_Q)
	{
		RootController.Player.Actor.ConsoleCommand("exit");
		return true;
	}

	Key = ConvertJoystick(Key);

	if (bQuery)
	{
		// handle up/down keys
		if( Action == IST_Press && (Key == IK_Up || Key == IK_MouseWheelUp || Key == IK_Joy9) )
		{
			if (fKeyDown == IK_None)
			{
				ChangeSelection(-1);
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
				ChangeSelection(1);
				fKeyDown = IK_Down;
			}
		}
		else if( Action == IST_Release && (Key == IK_Down || Key == IK_MouseWheelDown || Key == IK_Joy10) )
		{
			if (fKeyDown == IK_Down)
				fKeyDown = IK_None;
		}
	}
	
	if (bInteractive)
	{
		if( Action == IST_Press && (Key == IK_Enter || Key == IK_Space || Key == IK_LeftMouse ||
			Key == IK_Joy1) )
		{
			if (fKeyDown == IK_None)
				fKeyDown = IK_LeftMouse;
		}
		else if( Action == IST_Press && (Key == IK_Backspace || Key == IK_Escape ||
			Key == IK_RightMouse || Key == IK_Joy2) )
		{
			if (fKeyDown == IK_None)
				fKeyDown = IK_RightMouse;
		}
		else if( Action == IST_Release && (Key == IK_Enter || Key == IK_Space || Key == IK_LeftMouse ||
			Key == IK_Joy1) )
		{
			//RootController.PlaySound( fClickSound );
			//ParentInteraction.EndMenu(self, 0);
			if (fKeyDown == IK_LeftMouse)
			{
				fKeyDown = IK_None;
				Holder.UserResponce(fSelItem); // fSelItem is 0 for non-choice display (which is a good value)
			}
		}
		else if( Action == IST_Release && (Key == IK_Backspace || Key == IK_Escape ||
			Key == IK_RightMouse || Key == IK_Joy2) )
		{
			//RootController.PlaySound( fCancelSound );
			//ParentInteraction.EndMenu(self, -1);
			if (fKeyDown == IK_RightMouse)
			{
				fKeyDown = IK_None;
				Holder.UserResponce(-1);
			}
		}

		return true;
	}

	return false;
}

defaultproperties
{
	fFullFrameTopLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_top_left'
	fFullFrameTopRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_top_right'
	fFullFrameMiddleLeft=Texture'B9Menu_textures.Full_Size_Panes.full_frame_middle_left'
	fFullFrameMiddleRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_middle_right'
	fFullFrameBottomLeft=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_left'
	fFullFrameBottomRight=TexScaler'B9Menu_textures.Full_Size_Panes.full_frame_bottom_right'
	fMoreArrow=Texture'B9Menu_textures.Misc.blinky_arrow_a00'
	fYesNoLeft=Texture'B9MenuHelp_Textures.Choices.yes_no_left'
	fYesNoRight=Texture'B9MenuHelp_Textures.Choices.yes_no_right'
	fNewline="
"
	CinematicsRatio=1.66
}