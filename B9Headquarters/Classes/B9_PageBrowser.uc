/////////////////////////////////////////////////////////////
// B9_PageBrowser
//

class B9_PageBrowser extends Object;

var int fImageBorder;
var() localized string B9Fonts;

struct PageState
{
	var font Font;
	var color Color;
	var bool Shadow;
	var bool Center;
};

struct ImageEntry
{
	var texture Texture;
	var int u;
	var int v;
	var int w;
	var int h;
	var int top;
	var bool rightAlign;
};

struct PageBox
{
	var int left;
	var int top;
	var int width;
	var int height;
	var array<ImageEntry> images;
};

struct TextEntry
{
	var PageState TheState;
	var string TheText;
	var int x;
	var int y;
};

struct PageCache
{
	var PageBox box;
	var array<TextEntry> strings;
};

var PageCache TheCache;
var bool CacheValid;

var() localized string B9FontName;

//function font LoadFont( String fontName )
//{
//	return font( DynamicLoadObject( B9Fonts $ fontName, class'Font' ) );
//}

function font LoadFontEx( String fontName, int pitch )
{
	return font( DynamicLoadObject( B9Fonts $ fontName $ string( Pitch ), class'Font' ) );

	//local Font myFont;

	//myFont = font( DynamicLoadObject( B9Fonts $ fontName $ string( Pitch ), class'Font' ) );

	//if ( myFont == None )
	//{
	//	Log( "SCDTemp/B9Headquarters.B9_PageBrowser::LoadFontEx():No myFont," $ B9Fonts $ fontName $ string( Pitch ) );
	//}
	//else
	//{
	//	Log( "SCDTemp/B9Headquarters.B9_PageBrowser::LoadFontEx(): myFont is"$myFont.Name );
	//}
	
	//return myFont;

}

function float LeftMargin(PageBox box, float y)
{
	local int i;
	local ImageEntry ie;

	for (i=0;i<box.images.Length;i++)
	{
		ie = box.images[i];

		if (!ie.rightAlign && y >= ie.top && y < ie.top + ie.h + fImageBorder)
			return float(box.left + ie.w + fImageBorder);
	}

	return float(box.left);
}

function float RightMargin(PageBox box, float y)
{
	local int i;
	local ImageEntry ie;

	for (i=0;i<box.images.Length;i++)
	{
		ie = box.images[i];

		if (ie.rightAlign && y >= ie.top && y < ie.top + ie.h + fImageBorder)
			return float(box.left + box.width - ie.w - fImageBorder);
	}

	return float(box.left + box.width);
}

function DrawPageText( canvas Canvas, PageBox box, out float x, out float y, string s, int limit,
					   bool shadow, bool center, bool cache )
{
	local string text;
	local int n, k, i, j;
	local float sx, sy;
	local string chopped;
	local float rm;
	local Color oldColor;
	local int offset;
	local float dx, dy;
	local bool didChop;

//	Canvas.Style = Actor.ERenderStyle.STY_Alpha;
	Canvas.Style = 1;
	
	k = 0;

	text = s;
	n = Len(text);
	rm = RightMargin(box, y);	

	while (true)
	{
		Canvas.TextSize( text, sx, sy );
		while (sx > rm - x)
		{
			n -= 1;
			j = -1;

			didChop = false;
			while (n > 0)
			{
				chopped = Right(text, 1);
				text = Left(text, n);
				if (Right(text,1) != " ")
				{
					if (chopped == " ") break;
					if (chopped == "-" && didChop)
					{
						text = text $ "-";
						n++;
						break;
					}
				}
				n -= 1;		
				didChop = true;

				Canvas.TextSize( text, sx, sy );
				if (j == -1 && sx <= rm - x)
					j = n;
			}

			if (n == 0)
			{
				if (x == LeftMargin(box, y))
				{
					// oops, the whole word doesn't fit!!
					if (j == -1) return;
					n = j;
					text = Mid(s, k, n);
					break;
				}

				Canvas.TextSize( "Wg", sx, sy );
				y += int(sy);
				x = LeftMargin(box, y);
				rm = RightMargin(box, y);
				text = Mid(s, k);
				if (Left(text,1) == " ")
				{
					text = Mid(text,1);
					k += 1;
				}
				n = Len(text);
				if (n == 0) return;
			}

			Canvas.TextSize( text, sx, sy );
		}

		if (k + n >= limit)
		{
			n = limit - k;
			if (n <= 0)
				return;
			text = Left(text, n);
		}

		dx = x;
		dy = y;
		if (center)
			dx += (RightMargin(box, y) - LeftMargin(box, y) - sx) / 2;
		if (shadow)
		{
			if (sy > 16.0) offset = 2;
			else offset = 1;
			Canvas.ClipX += offset;
			oldColor = Canvas.DrawColor;
			Canvas.SetDrawColor(0, 0, 0);
			Canvas.SetPos( dx + offset, dy + offset );
			Canvas.DrawText( text, false );			
			Canvas.DrawColor = oldColor;
			Canvas.ClipX -= offset;
		}
		Canvas.SetPos( dx, dy );
		Canvas.DrawText( text, false );
						
		if (cache)
		{
			i = TheCache.strings.Length;
			TheCache.strings.Length = i + 1;
			TheCache.strings[i].TheState.Font = Canvas.Font;
			TheCache.strings[i].TheState.Color = Canvas.DrawColor;
			TheCache.strings[i].TheState.Shadow = shadow;
			TheCache.strings[i].TheState.Center = center; // not needed really
			TheCache.strings[i].TheText = text;
			TheCache.strings[i].x = dx;
			TheCache.strings[i].y = dy;
		}

		x += sx;

		if (k + n >= limit)
			return;

		Canvas.TextSize( "Wg", sx, sy );
		y += int(sy);
		x = LeftMargin(box, y);
		rm = RightMargin(box, y);

		k += n;
		text = Mid(s, k);
		if (Left(text,1) == " ")
		{
			text = Mid(text,1);
			k += 1;
		}
		n = Len(text);
	}
}

function bool RenderPageInternal( canvas Canvas, array<string> bodies, int limit, bool cache )
{
	local color black, white, Color;
	local int bodyLen;
	local int i, j, k;
	local int start;
	local PageBox box;
	local PageState ps;
	local array<PageState> psa;
	local int stackSize;
	local font tempFont;
	local string tempStr;
	local float x, y;
	local float sx, sy;
	local ImageEntry img;
	local string body;
	local bool recalc;
	local bool all;
	local bool shadow;
	local bool center;
	local string fragment;

	stackSize = 0;
	all = false;
	shadow = false;
	center = false;

	white.R = 255;
	white.G = 255;
	white.B = 255;

	black.R = 0;
	black.G = 0;
	black.B = 0;

	Color = white;

	box.left = 0;
	box.top = 0;
	box.width = Canvas.ClipX;
	box.height = Canvas.ClipY;

	x = box.left;
	y = box.top;

	if (cache)
	{
		TheCache.box = box;
		TheCache.strings.Length = 0;
	}

	for (k=0;k<bodies.Length;k++)
	{
		body = bodies[k];
		bodyLen = Len(body);
		i = 0;
		start = -1;

		while (i < bodyLen)
		{
			if (Mid(body,i,1) == "<")
			{
				if (start != -1)
				{
					if (limit == 0)
						return false;

					j = i - start;
					if (j > limit)
						j = limit;

					fragment = Mid(body,start,i - start);
					Canvas.SetDrawColor(Color.R, Color.G, Color.B);
					DrawPageText(Canvas, box, x, y, fragment, j, shadow, center, cache);

					limit -= j;
					if (limit == 0)
						return false;

					start = -1;
				}

				i += 1;
				if (Mid(body,i,1) == "/")
				{
					i += 1;
					j = 0;
					if (Mid(body,i,5) == "font>")
					{
						j = 5;
					}
					else if (Mid(body,i,7) == "shadow>" || Mid(body,i,7) == "center>")
					{
						j = 7;
					}
					if (j > 0)
					{
						if (stackSize > 0)
						{
							stackSize -= 1;
							Canvas.Font = psa[stackSize].Font;
							Color = psa[stackSize].Color;
							shadow = psa[stackSize].Shadow;
							center = psa[stackSize].Center;
						}

						i += j;
					}
					else { all = true; break; }
				}
				else
				{
					if (Mid(body,i,7) == "center>")
					{
						ps.Font = Canvas.Font;
						ps.Color = Color;
						ps.Shadow = shadow;
						ps.Center = center;

						if (psa.Length == stackSize)
							psa.Length = psa.Length + 5;

						psa[stackSize] = ps;
						stackSize += 1;

						center = true;
						i += 7;
					}
					else if (Mid(body,i,7) == "shadow>")
					{
						ps.Font = Canvas.Font;
						ps.Color = Color;
						ps.Shadow = shadow;
						ps.Center = center;

						if (psa.Length == stackSize)
							psa.Length = psa.Length + 5;

						psa[stackSize] = ps;
						stackSize += 1;

						shadow = true;
						i += 7;
					}
					else if (Mid(body,i,5) == "font ")
					{
						ps.Font = Canvas.Font;
						ps.Color = Color;
						ps.Shadow = shadow;
						ps.Center = center;

						if (psa.Length == stackSize)
							psa.Length = psa.Length + 5;

						psa[stackSize] = ps;
						stackSize += 1;

						i += 5;
						while (i < bodyLen && Mid(body,i,1) != ">")
						{
							if (Mid(body,i,6) == "size=\"")
							{
								i += 6;
								j = InStr(Mid(body,i), "\"");
								if (j == -1) { all = true; break; }// error

								tempFont = LoadFontEx( B9FontName, int(Mid(body,i,j)) );
								if (tempFont != None)
									Canvas.Font = tempFont;

								i += j + 1;
							}
							else if (Mid(body,i,7) == "color=\"")
							{
								i += 7;
								j = InStr(Mid(body,i), "\"");
								if (j == -1) { all = true; break; }// error

								tempStr = Mid(body,i,j);

								if (tempStr == "white")
								{
									Color.R = 255; Color.G = 255; Color.B = 255;
								}
								else if (tempStr == "black")
								{
									Color.R = 0; Color.G = 0; Color.B = 0;
								}
								else if (tempStr == "red")
								{
									Color.R = 255; Color.G = 0; Color.B = 0;
								}
								else if (tempStr == "green")
								{
									Color.R = 0; Color.G = 255; Color.B = 0;
								}
								else if (tempStr == "lightgreen")
								{
									Color.R = 128; Color.G = 255; Color.B = 128;
								}
								else if (tempStr == "blue")
								{
									Color.R = 0; Color.G = 0; Color.B = 255;
								}
								else if (tempStr == "yellow")
								{
									Color.R = 255; Color.G = 255; Color.B = 0;
								}
								else if (tempStr == "cyan")
								{
									Color.R = 0; Color.G = 255; Color.B = 255;
								}
								else if (tempStr == "gray")
								{
									Color.R = 128; Color.G = 128; Color.B = 128;
								}

								i += j + 1;
							}
							else
							{
								i += 1;
							}
						}

						i += 1;
					}
					else if (Mid(body,i,4) == "img ")
					{
						//<img src="name" align="left" u="0" v="0" w="256" h="256"> 

						img.Texture = None;
						img.rightAlign = false;
						img.u = 0;
						img.v = 0;
						img.w = 256;
						img.h = 256;

						i += 4;
						while (i < bodyLen && Mid(body,i,1) != ">")
						{
							if (Mid(body,i,5) == "src=\"")
							{
								i += 5;
								j = InStr(Mid(body,i), "\"");
								if (j == -1) { all = true; break; }// error

								img.Texture = texture(DynamicLoadObject( Mid(body,i,j), class'Texture' ));
								i += j + 1;
							}
							else if (Mid(body,i,7) == "align=\"")
							{
								i += 7;
								img.rightAlign = (Mid(body,i,6) == "right\"");
								i += InStr(Mid(body,i), "\"") + 1;
							}
							else if (Mid(body,i,3) == "u=\"")
							{
								i += 3;
								j = InStr(Mid(body,i), "\"");
								if (j == -1) { all = true; break; }// error

								img.u = int(Mid(body,i,j));
								i += j + 1;
							}
							else if (Mid(body,i,3) == "v=\"")
							{
								i += 3;
								j = InStr(Mid(body,i), "\"");
								if (j == -1) { all = true; break; }// error

								img.v = int(Mid(body,i,j));
								i += j + 1;
							}
							else if (Mid(body,i,3) == "w=\"")
							{
								i += 3;
								j = InStr(Mid(body,i), "\"");
								if (j == -1) { all = true; break; }// error

								img.w = int(Mid(body,i,j));
								i += j + 1;
							}
							else if (Mid(body,i,3) == "h=\"")
							{
								i += 3;
								j = InStr(Mid(body,i), "\"");
								if (j == -1) { all = true; break; }// error

								img.h = int(Mid(body,i,j));
								i += j + 1;
							}
							else
							{
								i += 1;
							}
						}

						i += 1;
						recalc = false;
						j = y;

						if (img.rightAlign)
						{
							if (x >= box.left + box.width - img.w - 4)
							{
								Canvas.TextSize( "Wg", sx, sy );
								y += int(sy);
								j = y;
								recalc = true;
							}

							Canvas.SetPos(box.left + box.width - img.w, j);
						}
						else
						{
							if (LeftMargin(box, y) != x)
							{
								Canvas.TextSize( "Wg", sx, sy );
								j = y + int(sy);
							}

							Canvas.SetPos(box.left, j);
						}

						img.top = j;
						Canvas.DrawTile(img.Texture, img.w, img.h, img.u, img.v, img.w, img.h);

						j =  box.images.Length;
						box.images.Length = j + 1;
						box.images[j] = img;

						if (cache)
						{
							TheCache.box.images.Length = j + 1;
							TheCache.box.images[j] = img;
						}

						if (recalc)
							x = LeftMargin(box, y);
					}
					else if (Mid(body,i,4) == "br/>")
					{
						Canvas.TextSize( "Wg", sx, sy );
						y += int(sy);
						x = LeftMargin(box, y);
						i += 4;
					}
					else { all = true; break; } // error
				}
			}
			else
			{
				if (start == -1)
					start = i;
				i += 1;
			}
		}

		if (start != -1)
		{
			if (limit == 0)
				return false;

			j = i - start;
			if (j > limit)
				j = limit;

			fragment = Mid(body,start,i - start);
			Canvas.SetDrawColor(Color.R, Color.G, Color.B);
			DrawPageText(Canvas, box, x, y, fragment, j, shadow, center, cache);

			limit -= j;
			if (limit == 0)
				return false;
		}
	}

	return (all || k == bodies.Length);
}

function RenderFromCache( canvas Canvas )
{
	local int i;
	local ImageEntry img;
	local float sx, sy;
	local int offset;
	local Color oldColor;
	local font oldFont;
	local TextEntry se;

	for (i=0;i<TheCache.box.images.Length;i++)
	{
		img = TheCache.box.images[i];
		Canvas.DrawTile(img.Texture, img.w, img.h, img.u, img.v, img.w, img.h);
	}

	oldColor = Canvas.DrawColor;
	oldFont = Canvas.Font;
	for (i=0;i<TheCache.strings.Length;i++)
	{
		se = TheCache.strings[i];
		Canvas.Font = se.TheState.Font;
		if (se.TheState.shadow)
		{
			Canvas.TextSize( se.TheText, sx, sy );
			if (sy > 16.0) offset = 2;
			else offset = 1;
			Canvas.ClipX += offset;
			Canvas.SetDrawColor(0, 0, 0);
			Canvas.SetPos( se.x + offset, se.y + offset );
			Canvas.DrawText( se.TheText, false );			
			Canvas.ClipX -= offset;
		}
		Canvas.DrawColor = se.TheState.Color;
		Canvas.SetPos( se.x, se.y );
		Canvas.DrawText( se.TheText, false );
	}
	Canvas.Font = oldFont;
	Canvas.DrawColor = oldColor;
}

function bool RenderPage( canvas Canvas, array<string> bodies, int limit, bool cache )
{
	local bool ok;

	if (!cache && CacheValid)
	{
		RenderFromCache( Canvas );
		return true;
	}

	if (cache)
		CacheValid = false;
	ok = RenderPageInternal( Canvas, bodies, limit, cache );
	if (cache)
	{
		CacheValid = true;
	}
	return ok;
}

defaultproperties
{
	fImageBorder=4
	B9Fonts="B9_Fonts."
	B9FontName="MicroscanA"
}