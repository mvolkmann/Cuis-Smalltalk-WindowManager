'From Cuis7.3 [latest update: #7044] on 8 February 2025 at 2:41:06 pm'!
'Description '!
!provides: 'WindowManager' 1 35!
SystemOrganization addCategory: #WindowManager!


!classDefinition: #IconsWindow category: #WindowManager!
SystemWindow subclass: #IconsWindow
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'WindowManager'!
!classDefinition: 'IconsWindow class' category: #WindowManager!
IconsWindow class
	instanceVariableNames: ''!

!classDefinition: #Icon category: #WindowManager!
PlacedMorph subclass: #Icon
	instanceVariableNames: 'iconName'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'WindowManager'!
!classDefinition: 'Icon class' category: #WindowManager!
Icon class
	instanceVariableNames: ''!

!classDefinition: #WindowManager category: #WindowManager!
Object subclass: #WindowManager
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'WindowManager'!
!classDefinition: 'WindowManager class' category: #WindowManager!
WindowManager class
	instanceVariableNames: ''!


!IconsWindow methodsFor: 'as yet unclassified' stamp: 'RMV 2/8/2025 14:22:04'!
initialize
	| atRowEnd column iconsPerRow iconSelectors row |
	
	super initialize.
	
	canColorLayouts := true.
	self setLabel: 'Theme Icons'.
	
	column := self layoutMorph.
	column color: Color white; separation: 10.

	iconSelectors := Theme current class allSelectors
		select: [ :selector | selector endsWith: #Icon ] :: asSortedCollection.

	iconsPerRow := 10.
	row := nil.
	atRowEnd := true.
	
	iconSelectors withIndexDo: [ :selector :index |
		row ifNil: [
			row := LayoutMorph newRow
				axisEdgeWeight: 0;
				color: Color white;
				separation: 10.
			row layoutSpec
				proportionalWidth: 0;
				offAxisEdgeWeight: 0.
			column addMorph: row.
		].
	
		row addMorph: (IconsWindow buildCell: selector) "fixedWidth: 250".
		
		atRowEnd := (index mod: iconsPerRow) = 0.
		atRowEnd ifTrue: [ row := nil ].
	].

	atRowEnd ifFalse: [ column addMorph: row ].! !

!IconsWindow class methodsFor: 'as yet unclassified' stamp: 'RMV 2/8/2025 14:12:43'!
open
		
	self new openInWorld! !

!IconsWindow class methodsFor: 'private' stamp: 'RMV 2/8/2025 14:15:05'!
buildCell: selector
	| label |

	"Removes the word 'Icon' from the end."
	label := LabelMorph contents: (selector allButLast: 4) :: color: Color blue.
	^ LayoutMorph newColumn
		color: Color tan muchLighter;
		padding: 6;
		addMorph: (Icon name: selector);
		addMorph: label.! !

!Icon methodsFor: 'private' stamp: 'RMV 2/7/2025 16:24:57'!
name: aSymbol

	iconName := aSymbol! !

!Icon methodsFor: 'drawing' stamp: 'RMV 2/7/2025 20:35:15'!
drawOn: aCanvas
	| icon |
	
	[
		icon := Theme current perform: iconName. "a Form object"
		icon := icon magnifyBy: 2.0. "TODO: Why does this have no effect?"
		aCanvas image: icon at: 0 @ 0.
	] on: Error do: [
		'No instance method "{1}" was found in the Theme class' format: { iconName } :: print
	]! !

!Icon class methodsFor: 'as yet unclassified' stamp: 'RMV 2/7/2025 16:24:21'!
name: aSymbol

	^ self new name: aSymbol
! !

!WindowManager class methodsFor: 'menu-world' stamp: 'RMV 2/7/2025 20:56:25'!
worldMenuOptions
	
	^`{
		{
			#submenuOf -> TheWorldMenu windowsLabel.
			#itemGroup -> 50.
			#itemOrder -> 10.
			#label -> 'Save window locations & sizes'.
			#object -> WindowManager.
			#selector -> #saveWindows.
			#icon -> #saveIcon.
			#balloonText -> 'Saves the location and size of all open windows.'.
		} asDictionary.
		{
			#submenuOf -> TheWorldMenu windowsLabel.
			#itemGroup -> 50.
			#itemOrder -> 20.
			#label -> 'Restore window locations & sizes'.
			#object -> WindowManager.
			#selector -> #restoreWindows.
			#icon -> #refreshIcon.
			#balloonText -> 'Restores the location and size of all open windows.'.
		} asDictionary.
		{
			#submenuOf -> TheWorldMenu preferencesLabel.
			#itemGroup -> 10.
			#itemOrder -> 30.
			#label -> 'Open windows near world corners'.
			#object -> WindowManager.
			#selector -> #openNearCorners.
			#icon -> #windowIcon.
			#balloonText -> 'Sets preference to open windows near World corners'.
		} asDictionary.
		{
			#submenuOf -> TheWorldMenu preferencesLabel.
			#itemGroup -> 10.
			#itemOrder -> 40.
			#label -> 'Open windows at cursor location'.
			#object -> WindowManager.
			#selector -> #openAtCursor.
			#icon -> #windowIcon.
			#balloonText -> 'Sets preference to open windows at cursor location'.
		} asDictionary.
	}`

	! !

!WindowManager class methodsFor: 'preferences' stamp: 'RMV 2/7/2025 08:41:28'!
openAtCursor
	
	Preferences name: #openWindowLocation category: #gui value: 'at cursor'.
	Preferences saveToDisk: #openWindowLocation.! !

!WindowManager class methodsFor: 'preferences' stamp: 'RMV 2/7/2025 08:41:44'!
openNearCorners
	
	Preferences name: #openWindowLocation category: #gui value: 'near corners'.
	Preferences saveToDisk: #openWindowLocation.! !

!WindowManager class methodsFor: 'user interface' stamp: 'RMV 2/6/2025 19:26:38'!
restoreWindows
	"Restore the location and extent of each window described in a file."
	| fileEntry fileName height id line parts stream width window windows x y|
	
	windows := (SystemWindow windowsIn: self runningWorld satisfying: [ :w | w visible]).

	fileName := (SystemDictionary new imageName allButLast: 5), 'windows'.
	fileEntry := fileName asFileEntry.
	stream := fileEntry readStream.

	line := stream nextLine.
	[ line = nil ] whileFalse: [
		parts := line subStrings: ','.
		id := parts at: 1 :: asNumber.
		x := parts at: 3 :: asNumber.
		y := parts at: 4 :: asNumber.
		width := parts at: 5 :: asNumber.
		height := parts at: 6 :: asNumber.
		"'id={1} x={2} y={3} width={4} height={5}' format: {id. x. y. width. height} :: print."
		
		window := windows detect: [ :w | w morphId = id ] ifNone: [].
		window ifNotNil: [
			window morphPosition: x@y.
			window morphExtent: width@height.
		].
		
		line := stream nextLine.
	].

	'restored window positions and locations from' print.
	fileName print.! !

!WindowManager class methodsFor: 'user interface' stamp: 'RMV 2/6/2025 19:26:24'!
saveWindows
	"Write the id, location, and extent of each visible window to a file."
	| fileEntry fileName windows |

	fileName := (SystemDictionary new imageName allButLast: 5), 'windows'.
	fileEntry := fileName asFileEntry.
	windows := (SystemWindow windowsIn: self runningWorld satisfying: [ :w | w visible]).
	
	fileEntry forceWriteStreamDo: [:fileStream |
		windows do: [:window |
			| extent message position template |

			position := window morphPosition.
			extent := window morphExtent.
			template := '{1},{2},{3},{4},{5},{6}'.
			message := template format: {
				window morphId.
				window label.
				position x.
				position y.
				extent x.
				extent y
			}.
			fileStream nextPutAll: message; newLine.
		]
	].

	'saved window positions and sizes in' print.
	fileName print.! !

!SystemWindow methodsFor: '*WindowManager' stamp: 'RMV 2/8/2025 14:19:18'!
canColorLayouts: aBoolean

	canColorLayouts := aBoolean! !

!SystemWindow methodsFor: '*WindowManager' stamp: 'RMV 2/8/2025 14:20:52'!
initialize
	"Initialize a system window. Add label, stripes, etc., if desired"

	super initialize.
	canColorLayouts := false.
	labelString ifNil: [ labelString := 'Untitled Window'].
	
	self initializeLabelArea.
	extent := `300 @ 200`.

	self initializeAdjusters.

	"by default"
	self beColumn! !

!SystemWindow methodsFor: '*WindowManager' stamp: 'RMV 2/7/2025 08:55:49'!
openAtCursor: aWorld
	| fromMenu position sender windowExtent windowHeight windowRect windowWidth worldExtent worldHeight worldWidth |
	
	"Determine whether this method was invoked from a menu selection".
	fromMenu := false.
	sender := thisContext sender.
	[ sender notNil and: [ fromMenu not ] ] whileTrue: [
		fromMenu := sender receiver class = MenuMorph.
		sender := sender sender.
	].

	"Determine the goal position for the upper-left corner of the window."
	position := fromMenu
		ifTrue: [ Smalltalk at: #worldClickPosition ]
		ifFalse: [ self runningWorld activeHand location translation ].
	
	"Get the size of the window."
	windowExtent := self morphExtent.
	"300@200 is the default assigned in the SystemWindow instance method initialize."
	windowExtent = `300 @ 200` ifTrue: [
		windowRect := self initialFrameIn: aWorld.
		windowExtent := windowRect extent.
	].
	self morphExtent: windowExtent.
	windowWidth := windowExtent x.
	windowHeight := windowExtent y.
		
	"Get the size of the World."
	worldExtent := aWorld morphExtent.
	worldWidth := worldExtent x.
	worldHeight := worldExtent y.
		
	"It seems most windows automatically choose their size
	based on the World size, so this code isn't really necessary."
	"Handle case where window is wider than World."
	windowWidth > worldWidth ifTrue: [
		self morphExtent: (Point x: worldWidth y: windowHeight).
		position := Point x: 0 y: position y.
	].		
	"Handle case where window is taller than World."
	windowHeight > worldHeight ifTrue: [
		self morphExtent: (Point x: windowWidth y: worldHeight).
		position := Point x: position x y: 0.
	].

	"If window extends past right side of world, move it left."
	position x + windowWidth > worldWidth ifTrue: [
		position := Point x: (worldWidth - windowWidth) y: position y
	].

	"If window extends past bottom side of world, move it up."
	position y + windowHeight > worldHeight ifTrue: [
		position := Point x: position x y: (worldHeight - windowHeight)
	].

	aWorld addMorph: self position: position.! !

!SystemWindow methodsFor: '*WindowManager' stamp: 'RMV 2/8/2025 14:20:08'!
openInWorld
	"Ensure all widgets have proper colors before opening"
	canColorLayouts ifFalse: [
		Theme current widgetsColorFromToolColor ifTrue: [
			self widgetsColor: self windowColor ].
	].
	super openInWorld! !

!SystemWindow methodsFor: '*WindowManager' stamp: 'RMV 2/7/2025 08:58:09'!
openInWorld: aWorld

	(Preferences at: #openWindowLocation) = 'at cursor'
		ifTrue: [ self openAtCursor: aWorld ]
		ifFalse: [ self openNearCorner: aWorld ]! !

!SystemWindow methodsFor: '*WindowManager' stamp: 'RMV 2/7/2025 08:55:34'!
openNearCorner: aWorld
	"This was copied from openInWorld: in the base image."
	| frameRect |
	
	frameRect := self initialFrameIn: aWorld.
	self morphExtent: frameRect extent.
	aWorld addMorph: self position: frameRect topLeft.! !
