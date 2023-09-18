class LinkedList extends Object;

var private LinkedListElement	fTop;
var private LinkedListElement	fBottom;
var private int					fCount;

var private LinkedListElement	kNone;

function LinkedList _LinkedList()
{
	return self;
}

function LinkedListElement CreateLink( Object object, out LinkedListElement last, out LinkedListElement next )
{
	local LinkedListElement newLink;
	newLink = (new(None) class'LinkedListElement')._LinkedListElement();
	
	// Init new link
	newLink.fNext = next;
	newLink.fLast = last;
	newLink.fObject = object;

	if( next != None )
	{
		next.fLast = newLink;
	}

	if( last != None )
	{
		last.fNext = newLink;
	}

	return newLink;
}

function PushBack( Object object )
{
	local LinkedListElement newLink;
	newLink = CreateLink( object, fBottom, kNone );  
	
	// Correct data
	if( fCount == 0 )
	{
		fTop = newLink; 		
	}
	fBottom = newLink;
	fCount++;
}

function PushFront( Object object )
{
	local LinkedListElement newLink;
	newLink = CreateLink( object, kNone, fTop );  
	
	// Correct data
	if( fCount == 0 )
	{
		fBottom = newLink; 		
	}
	fTop = newLink;
	fCount++;	
}


function Object PopBack()
{
	local LinkedListElement back;		
	back = GetBottom();

	RemoveElement( back );

	return back.fObject;
}

function Object PopFront()
{
	local LinkedListElement front;		
	front = GetTop();

	RemoveElement( front );

	return front.fObject;	
}

function AddElement( Object object, out LinkedListElement insertAfter )
{
	local LinkedListElement newLink;
	newLink = CreateLink( object, insertAfter, insertAfter.fNext ); 

	// Correct data
	if( insertAfter == fBottom )
	{
		fBottom = newLink;
	}
	fCount++;
}

function RemoveElement( out LinkedListElement element )
{
	if( element == fTop )
	{
		fTop = fTop.fNext;
	}
	else if( element == fBottom )
	{
		fBottom = fBottom.fLast;
	}

	if( element.fLast != None )
	{
		element.fLast.fNext = element.fNext;	
	}

	if( element.fNext != None )
	{
		element.fNext.fLast = element.fLast;	
	}

	element.fNext = None;
	element.fLast = None;

	fCount--;
}

function Clear()
{
	local LinkedListElement element;

	element = GetTop();

	while ( element != None )
	{
		element.fObject = None;
		PopFront();
		element = GetTop();
	}

	fCount = 0;	
	fTop = None;
	fBottom = None;

}


function LinkedListElement FindElement( object objectToFind )
{
	local LinkedListElement element;

	element = GetTop();

	while ( element != None )
	{
		if ( element.fObject == objectToFind )
			break;

		element = element.fNext;
	}

	return element;
}


function Swap( out LinkedListElement firstElement, out LinkedListElement secondElement )
{
	local LinkedListElement firstNext;
	local LinkedListElement firstLast;
	firstNext = firstElement.fNext;
	firstLast = firstElement.fLast;

	firstElement.fNext = secondElement.fNext;
	firstElement.fLast = secondElement.fLast;

	secondElement.fNext = firstNext;
	secondElement.fLast = firstLast;
}


function Object GetElement( int index )
{
	local int i;
	local LinkedListElement element;

	if ( ( index < 0 ) || ( index >= fCount ) )
	{
		Log( "ERROR LinkedList: Invalid index (" $ index $ ") (count=" $ fCount $ ")" );
		return None;
	}

	i = 0;
	for ( element = fTop; ( element != None ) && ( i < index ); element = element.fNext )
	{
		i++;
	}

	if ( element == None )
		return None;

	return element.fObject;
}


function LinkedListElement GetTop()
{
	return fTop;
}

function LinkedListElement GetBottom()
{
	return fBottom;
}

function int GetCount()
{
	return fCount;
}
