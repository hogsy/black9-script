// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class MyTestMultiColumnList extends GUIMultiColumnList;

struct MyTestItem
{
	var string	Caption;
	var int		Value;
	var string 	Key;
};

var() array<MyTestItem> MyData;
var GUIStyles SelStyle;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i,j,c;

	c = rand(50)+50;

    for (i=0;i<c;i++)
    {
    	j = MyData.Length;
    	MyData.Length = j+1;
        MyData[j].Caption = "This is a test";
        MyData[j].Value = rand(2000);
        MyData[j].Key = "KEY"@i;
        AddedItem();
    }

	// set delegates
	OnDrawItem	= MyOnDrawItem;

	Super.Initcomponent(MyController, MyOwner);
	SelStyle = Controller.GetStyle("SquareButton");
}

function Clear()
{
	MyData.Remove(0,MyData.Length);
	ItemCount = 0;
	Super.Clear();
}

function MyOnDrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected)
{
	local float CellLeft, CellWidth;

	// Draw the selection border
	if( bSelected )
		SelStyle.Draw(Canvas,MSAT_Pressed, X, Y-2, W, H+2 );

	GetCellLeftWidth( 0, CellLeft, CellWidth );
	Style.DrawText( Canvas, MenuState, X+CellLeft, Y, CellWidth, H, TXTA_Left, MyData[SortData[i].SortItem].Caption );

	GetCellLeftWidth( 1, CellLeft, CellWidth );
	Style.DrawText( Canvas, MenuState, X+CellLeft, Y, CellWidth, H, TXTA_Left, ""$MyData[SortData[i].SortItem].Value );

	GetCellLeftWidth( 2, CellLeft, CellWidth );
	Style.DrawText( Canvas, MenuState, X+CellLeft, Y, CellWidth, H, TXTA_Left, MyData[SortData[i].SortItem].Key );

}

function string GetSortString( int i )
{
    return MyData[i].Caption;
}

defaultproperties
{
	ColumnHeadings[0]="Caption"
	ColumnHeadings[1]="Value"
	ColumnHeadings[2]="Key"
	InitColumnPerc=/* Array type was not detected. */
	SortColumn=0
}