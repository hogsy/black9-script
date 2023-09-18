//=============================================================================
// B9MP_ServerBrowser.
//
// Description:
//		Use this to browse the server listings, either on the Internet or on LAN.
//
// Usage:
//		All B9MP_xxx classes have two types of variables, setup and runtime.  Any setup variables
//		must be set before using any functions of the class.  Runtime are typically checked after
//		the class has been ticked.
//
//		Setup:
//		fLAN				Set if browsing servers on the LAN instead of the internet
//		fCurrentFilter		Can be used to filter servers, it will not show servers that do not meet the filter spec.
//
//		Required:
//			Must call Tick() within the owning class's Tick()
//
//		To Browse:
//			The ServerBrowser will start looking for servers when you call Refresh().
//			As soon as that's done, it sets fServersDirty.  If it encounters an error, fBrowseResult
//			will contain kFailure and fErrorMessage will contain the error message.  Otherwise fServers will have the
//			list of server descriptions.  As soon as this list is copied or reflected, you must set fServersDirty to false.
//			While browsing, fBrowsing will be true.
//
//			The list of servers will also be filtered by fCurrentFilter and sorted by any sort rules.
//
//		Methods:
//		eResult Refresh()
//			Call this to refresh the list of servers.  List is ready when fServersDirty is true, as before.
//
//		eResult Join( B9MP_ServerDescription serverDescription )
//			<in flux> Call this to actually join the server chosen.
//
//		Filter()
//			Use to re-apply the filter to the server list (fServers).  Because a server description that has been filtered out
//			only has it's fVisible set to true, this can be called as often as desired.
//
//		ClearSort()
//			Call before adding sort fields.
//	
//		AddSortField( eServerSort field )
//			Add a sort field (criteria) for the sort.  Sort() uses the order as the priority of the sort (ping, then name, etc.)
//
//		Sort()
//			Re-sorts the server list, used if the sort criteria has changed.
//
//	Notes:
//		Filter and Sort are not yet implemented, but the interfaces are.
//
//
//
//=============================================================================
class B9MP_ServerBrowser extends B9MP_Online
	native;


enum eServerBrowserStatusCode
{
	kSBSNoStatusCode,		
	kSBSSearching,
	kSBSSearchCompleted,
	kSBSInvalidStatusCode3,		// Cannot be searching and completed in at the same time
	kSBSSearchFailed
};


// Setup
var bool					fLAN;						// If true, fServers is populated with servers found on the LAN only.  If false, internet servers only
var B9MP_ServerFilter		fCurrentFilter;				// Will use this filter to prune the server list as necessary.

// Runtime
var bool					fBrowsing;
var bool					fServersDirty;				// if true, fServers has been changed (result of a Refresh() for example).  Set to false when the contents have been read.
var eResult					fBrowseResult;
var String					fErrorMessage;
var LinkedList				fServers;

// Internal
var private int				fNumSortFields;
var private eServerSort		fSortFields[ kMaxSortFields ];


/************************************************************************************************************
 *
 *	PreBeginPlay
 *		
 *
 *
 ************************************************************************************************************/

event PreBeginPlay()
{
	if ( fServers == None )
	{
		fServers = (new(None) class'LinkedList')._LinkedList();
	}
}
  

/************************************************************************************************************
 *
 *	PreJoinGame
 *		In case the browser needs to prepare for joining the particular server.
 *
 *
 ************************************************************************************************************/

function eResult PreJoinGame( B9MP_ServerDescription ServerDescription )
{	
	return kSuccess;
}
  

/************************************************************************************************************
 *
 *	Destroyed
 *		
 *
 *
 ************************************************************************************************************/

event Destroyed()
{
	fServers.Clear();

	Super.Destroyed();
}


/************************************************************************************************************
 *
 *	Refresh
 *		Request a refresh of the server list.
 *
 *
 ************************************************************************************************************/

function eResult Refresh()
{
	return kSuccess;
}


/************************************************************************************************************
 *
 *	Join
 *		Will actually join the server requested.
 *
 *
 ************************************************************************************************************/

function eResult Join( B9MP_ServerDescription serverDescription )
{
	return kSuccess;
}


/************************************************************************************************************
 *
 *	Filter
 *		Applies fCurrentFilter to fServers, marking entries that do not qualify as invisible.
 *
 *
 ************************************************************************************************************/

function Filter()
{
}


/************************************************************************************************************
 *
 *	ClearSort
 *		When setting up the sort, call ClearSort, then AddSortField for each sort item, in the order of sort
 *		priority.
 *
 ************************************************************************************************************/

function ClearSort()
{
	fNumSortFields = 0;
}


/************************************************************************************************************
 *
 *	AddSortField
 *		Adds the field to be sorted next, allowing the sort order to change.
 *
 *
 ************************************************************************************************************/

function AddSortField( eServerSort field )
{
	if ( fNumSortFields < kMaxSortFields )
	{
		fSortFields[ fNumSortFields ] = field;
		fNumSortFields++;
	}
}


/************************************************************************************************************
 *
 *	Sort
 *		Sorts the fServer list based on the sort fields.
 *
 *
 ************************************************************************************************************/

function Sort()
{
	// No sort?
	if ( fNumSortFields == 0 )
	{
		return;
	}
}


