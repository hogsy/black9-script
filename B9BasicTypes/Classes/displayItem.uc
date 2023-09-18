class displayItem extends object;

// Due to issues with enum's I am using ints as enums until someone finds a better way.
const kTextPos_Left = 0;
const kTextPos_Right = 1;
const kTextPos_Center = 2;


var int					fStartX;
var int					fStartY;
var int					fWidth;
var int					fHeight;
var	int					fTextPositioning;
var	color				fTextColor;
var	color				fFocusColor;
var	color				fByeByeColor;
var font				fItemFont;
var material			fBaseImage;
var material			fFocusImage;
var string				fLabel;
var bool				fCanAcceptFocus;
var bool				fDrawNextItemTotheRight; // Instead of down
var bool				fDrawPartialInfo;
var	bool				fbStartByeByeTImerOnClick;

var int					fScreenPosX;
var int					fScreenPosY;
var int					fFinalDrawSizeX;
var int					fFinalDrawSizeY;

var float				fPercentTextureSizeX;
var float				fPercentTextureSizeY;
var	array<string>		fProcessedLabel;
var float				fProcessedLabelIncrement;
var bool				fWordWrap;

var displayItem			fEventParent;
var int					fEventID;

var bool				fInited;

// These should match the ones found in B9_MenuPDA_Menu.uc
const kFocus_NoFocus = 0;
const kFocus_StandardFocus = 1;
const kFocus_SelectedFocus = 2;


function Setup( B9_PDABase pdaBase );
function GainFocus();
function LostFocus();
function ChildEvent( displayItem item, int id );

// The begin and End points represent the clipping area of the draw function
function bool Draw(canvas Canvas, int focus, out int beginPoint_X, out int beginPoint_Y,int endPoint_X, int endPoint_Y, out B9_PDABase PDA)
{
	// First Draw the Image if there is one

	local font originalFont;
	local color originalDrawColor;
	local Texture ImageTexture;
	originalFont = Canvas.Font;
	Canvas.Font = fItemFont;

	
	originalDrawColor = Canvas.DrawColor;
	Canvas.CurX = Canvas.CurX + fStartX;
	Canvas.CurY = Canvas.CurY + fStartY;

	fScreenPosX = Canvas.CurX;
	fScreenPosY = Canvas.CurY;

	if (!fInited)
	{
		fInited = true;
		DetermineDimensions( Canvas, fFinalDrawSizeX, fFinalDrawSizeY,(endPoint_X - beginPoint_X),(endPoint_Y - beginPoint_Y) );
	}

//	log("BeginPoints X:"$beginPoint_X$" Y:"$beginPoint_Y);
//	log("EndPoints X:"$endPoint_X$" Y:"$endPoint_Y);
	if( ( fFinalDrawSizeX > (endPoint_X - beginPoint_X) || fFinalDrawSizeY > (endPoint_Y - beginPoint_Y) ) && fDrawPartialInfo == false)
	{
		
//		log(fProcessedLabel[0]$" is Too BIG!");
//		log("fFinalDrawSizeX:"$fFinalDrawSizeX$" fFinalDrawSizeY:"$fFinalDrawSizeY);
		// we don't want to draw after all
		return false;
	}
	
	if( fFocusImage != None ||  fBaseImage != None )
	{
		if(focus == kFocus_NoFocus || fCanAcceptFocus == false )
		{
			ImageTexture = Texture( fBaseImage );
			if( ImageTexture != None )
			{
				Canvas.DrawTileClipped( fBaseImage , ( fPercentTextureSizeX * ImageTexture.USize), (fPercentTextureSizeY * ImageTexture.VSize), 0, 0, ImageTexture.USize, ImageTexture.VSize);
			}
		}else // Draw Focus image if in bye bye mode or focus mode
		{
			ImageTexture = Texture( fFocusImage );
			if( ImageTexture != None )
			{
				Canvas.DrawTileClipped( fFocusImage , ( fPercentTextureSizeX * ImageTexture.USize), (fPercentTextureSizeY * ImageTexture.VSize), 0, 0, ImageTexture.USize, ImageTexture.VSize );
			}
		}
	}

	// Reset the String Display
	if( focus == kFocus_NoFocus )
	{
		Canvas.SetDrawColor(fTextColor.R, fTextColor.G, fTextColor.B);
	}else if( focus == kFocus_StandardFocus )
	{
		Canvas.SetDrawColor(fFocusColor.R, fFocusColor.G, fFocusColor.B);
	}else
	{
		Canvas.SetDrawColor(fByeByeColor.R, fByeByeColor.G, fByeByeColor.B);
	}

	DrawProcessedLabel(Canvas, fScreenPosX, fScreenPosY);
//	Canvas.DrawText( fLabel, false );
	if( fDrawNextItemTotheRight == true )
	{
		Canvas.CurY = fScreenPosY;
		Canvas.CurX = fScreenPosX + fFinalDrawSizeX;
		beginPoint_X = beginPoint_X + fFinalDrawSizeX;
		beginPoint_Y = Canvas.CurY;
	}else
	{
		Canvas.CurY = fScreenPosY + fFinalDrawSizeY;
		Canvas.CurX = PDA.fBeginPoint_X;
		beginPoint_Y = beginPoint_Y + fFinalDrawSizeY;
		beginPoint_X = Canvas.CurX;
		
	}
	Canvas.Font = originalFont;
	Canvas.DrawColor = originalDrawColor;
	return true;
}
function DrawProcessedLabel(canvas Canvas, int PosX, int PosY)
{
	local int index;
	for(index = 0; index < fProcessedLabel.length; index ++)
	{
		Canvas.CurX = PosX;
		Canvas.CurY = PosY + index * fProcessedLabelIncrement;
		Canvas.DrawText( fProcessedLabel[index], false );
	}
	
}
function DetermineDimensions( canvas Canvas, out int FinalX, out int FinalY,int SizeX,int SizeY )
{
	local float StringSizeX;
	local float StringSizeY;
	local int ImageSizeX;
	local int ImageSizeY;
	local int maxDataSizeX;
	local int maxDataSizeY;
	local Texture BackGroundImageTexture;

	FinalX = fWidth;
	FinalY = fHeight;
	BackGroundImageTexture = Texture(fBaseImage);
	
//	log("Background Texture is "$BackGroundImageTexture);
	
	if( FinalX != 0 && FinalY != 0 )
	{
		// By setting these values, it overrides the automatic sizing logic in this function,
		// so we bail.
		// But first at least process the Label
		ProcessLabel(Canvas,StringSizeX,StringSizeY,SizeX,SizeY);
		return;
	}

	if( FinalX == 0 || FinalY == 0 )
	{
		ProcessLabel(Canvas,StringSizeX,StringSizeY,SizeX,SizeY);
	}

	if( FinalX == 0 ) // If no Width Given see if the material given has the width needed
	{
		if( BackGroundImageTexture != None )
		{
			ImageSizeX = fPercentTextureSizeX * BackGroundImageTexture.USize;
//			log("ImageSizeX is  "$BackGroundImageTexture.USize);
		}

		if ( StringSizeX >  ImageSizeX )
		{
			FinalX = StringSizeX;
		}else
		{
			FinalX = ImageSizeX;
//			log("Using ImageSize X"$FinalX);
		}
	}
	if( FinalY == 0 )
	{
		if( BackGroundImageTexture != None )
		{
			ImageSizeY =  fPercentTextureSizeX * BackGroundImageTexture.VSize;
//			log("ImageSizeY is  "$BackGroundImageTexture.VSize);
		}
		if ( StringSizeY >  ImageSizeY )
		{
			FinalY = StringSizeY;
		}else
		{
			FinalY = ImageSizeY;
//			log("Using ImageSize Y"$FinalY);
		}
	}
	fWidth = FinalX; // Store these off now
	fHeight = FinalY;
	
}

function ProcessLabel(canvas Canvas, out float  StringSizeX,out float StringSizeY,int SizeX,int SizeY)
{
	local string stringConstructor;
	local string lastValidString;
	local float ConstructorX,ConstructorY;
	local int stringIndex,wordLength;
	local int strLen;
	strLen = Len(fLabel);
	Canvas.TextSize( fLabel, StringSizeX, StringSizeY );
	fProcessedLabelIncrement = StringSizeY;
	if( (StringSizeX <= SizeX) && (StringSizeY <= SizeY) )
	{
		fProcessedLabel.length = 1;
		fProcessedLabel[0] = fLabel;
	}else if( StringSizeY <= SizeY && fWordWrap == true)
	{
		// If The font is not too tall then we will try to word wrap to get around the X overflow
//		log("Trying to Word Wrap!");
		ConstructorX = 0;
		ConstructorY = 0;
		stringIndex = 0;
		stringConstructor = "";
		lastValidString = "";
		while( ConstructorX <= SizeX && ConstructorY <= SizeY && stringIndex <  strLen)
		{
//			log("stringIndex is "$stringIndex);
			GetWord( fLabel, stringIndex, wordLength );
			stringConstructor = stringConstructor $  Mid(fLabel,stringIndex,wordLength) ;
			Canvas.TextSize( stringConstructor, ConstructorX, ConstructorY );
//			Log("STRConst is "$stringConstructor);
//			Log("X:"$ConstructorX$" Y:"$ConstructorY);
//			Log("Wordlength is "$wordLength);
			if(ConstructorX <= SizeX)
			{
//				log(stringConstructor$" Is Valid and we will store it away");
				lastValidString = stringConstructor;
				stringIndex = stringIndex + wordLength;
			}else
			{
				if( lastValidString != "" )
				{
//					Log("Too Big, so we punt and use last valid string:"$lastValidString);
					fProcessedLabel.length = fProcessedLabel.length + 1;
					fProcessedLabel[fProcessedLabel.length-1] = lastValidString;
					stringConstructor = "";
					lastValidString = "";
					ConstructorX = 0;
				}else
				{
					if( fProcessedLabel.length == 0 )
					{
//						log("There is no way this string can be displayed it is too long and does not have any breaks:"$fLabel);
						return;
					}else
					{
						// No more words
//						log("We are done");
						stringIndex = strLen;
					}
				}
			}
		}
		if( lastValidString != "" )
		{
//			Log("Drop the last string in :"$lastValidString);
			fProcessedLabel.length = fProcessedLabel.length + 1;
			fProcessedLabel[fProcessedLabel.length-1] = lastValidString;
			stringConstructor = "";
			lastValidString = "";
			ConstructorX = 0;
		}
		StringSizeX = SizeX;
		StringSizeY = (fProcessedLabel.length * fProcessedLabelIncrement);
	}
	
}
// Adjusts stringIndex to start of first non-whitespace
// Ends scan at first whitespace after first non-whitespace detected.
function GetWord( string Label, out int stringIndex, out int wordLength )
{
	local int index;
	local int strLen;
	local bool whitespaceResult;
	wordLength = 0;
	// Find first non-white space
	if( Mid(Label,stringIndex,1) == " " )
		whitespaceResult = true;
	else
		whitespaceResult = false;
	strLen = Len(Label);
	index = stringIndex;
//	log("index is "$index);
//	log("Initial Whitespace is "$whitespaceResult);
	for(index = stringIndex; index < strLen && whitespaceResult == true; index++ )
	{
		stringIndex++;
//		log( "Incremnting stringIndex to "$stringIndex);
//		log( Mid(Label,index,1)  );
		if( Mid(Label,index,1) == " " )
			whitespaceResult = true;
		else
			whitespaceResult = false;
	}
	if( index >= strLen )
	{
//		log("All whitespace!");
		return;
	}
	wordLength++;
	for(index = stringIndex; index < strLen && Mid(Label,index,1) != " "; index++ )
	{
		wordLength++;
//		log(Mid(Label,index,1)$"'s WordLength is"$wordLength);
	}
//	log("Loop Over");
//	log(Mid(Label,index,1)$"'s WordLength is"$wordLength);
}

function bool handleKeyEvent( Interactions.EInputKey KeyIn, out Interactions.EInputAction Action, float Delta)
{
// Default handler handles nothing overload this to add functionality
	return false;
}

function ClickItem(optional B9_MenuPDA_Menu menu)
{
	// Defaults to .5 seconds
	if( fbStartByeByeTImerOnClick == true )
	{
		menu.BeginByeByeTimer();
	}
}
// This is the function that is called when the displayitem is selected
function ActOnClick(out B9_PDABase PDA,optional class<B9_MenuPDA_Menu> returnMenuClass)
{
	if( fEventParent != None )
	{
		fEventParent.ChildEvent( self, fEventID );
	}
}

function bool IsOver( int MouseX, int MouseY )
{
	local int XRight;
	local int YBottom;
	XRight = fScreenPosX + fWidth;
	YBottom = fScreenPosY + fHeight;

	if( MouseX >= fScreenPosX && MouseX <= XRight && MouseY >= fScreenPosY && MouseY <= YBottom )
	{
		return true;
	}
	else
	{
		return false;
	}
}

defaultproperties
{
	fTextColor=(B=0,G=190,R=60,A=255)
	fFocusColor=(B=220,G=255,R=220,A=255)
	fByeByeColor=(B=255,G=255,R=255,A=255)
	fItemFont=Font'B9_Fonts.MicroscanA20'
	fCanAcceptFocus=true
	fbStartByeByeTImerOnClick=true
	fPercentTextureSizeX=1
	fPercentTextureSizeY=1
}