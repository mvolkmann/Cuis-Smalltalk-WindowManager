'From Cuis7.3 [latest update: #7044] on 6 February 2025 at 7:28:04 pm'!
'Description '!
!provides: 'WindowManager' 1 13!
SystemOrganization addCategory: #WindowManager!


!classDefinition: #WindowManager category: #WindowManager!
Object subclass: #WindowManager
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'WindowManager'!
!classDefinition: 'WindowManager class' category: #WindowManager!
WindowManager class
	instanceVariableNames: ''!


!WindowManager class methodsFor: 'as yet unclassified' stamp: 'RMV 2/6/2025 19:26:38'!
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

!WindowManager class methodsFor: 'as yet unclassified' stamp: 'RMV 2/6/2025 19:26:24'!
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

!WindowManager class methodsFor: 'as yet unclassified' stamp: 'RMV 2/6/2025 19:27:23'!
worldMenuOptions
	
	^`{
		{
			#submenuOf -> TheWorldMenu windowsLabel.
			#itemGroup -> 50.
			#itemOrder -> 10.
			#label -> 'Save Window Locations & Sizes'.
			#object -> WindowManager.
			#selector -> #saveWindows.
			#icon -> #saveIcon.
			#balloonText -> 'Saves the location and size of all open windows.'.
		} asDictionary.
		{
			#submenuOf -> TheWorldMenu windowsLabel.
			#itemGroup -> 50.
			#itemOrder -> 20.
			#label -> 'Restore Window Locations & Sizes'.
			#object -> WindowManager.
			#selector -> #restoreWindows.
			#icon -> #openIcon.
			#balloonText -> 'Restores the location and size of all open windows.'.
		} asDictionary
	}`

	! !
