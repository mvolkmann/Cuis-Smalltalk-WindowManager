'From Cuis7.1 [latest update: #6883] on 13 December 2024 at 11:24:43 am'!
'Description '!
!provides: 'WindowManager' 1 7!



!SystemWindow class methodsFor: '*WindowManager' stamp: 'RMV 12/13/2024 11:24:21'!
restoreWindows
	"Restore the location and extent of each window described in a file."
	| fileEntry fileName height id line parts stream width window windows x y|
	
	windows := (SystemWindow windowsIn: self runningWorld satisfying: [ :w | w visible]).

	fileName := 'windows.txt'.
	fileEntry := fileName asFileEntry.
	stream := fileEntry readStream.

	line := stream nextLine.
	[ line = nil ] whileFalse: [
		parts := line subStrings: ','.
		id := parts at: 1 :: asInteger.
		x := parts at: 3 :: asInteger.
		y := parts at: 4 :: asInteger.
		width := parts at: 5 :: asInteger.
		height := parts at: 6 :: asInteger.
		"'id={1} x={2} y={3} width={4} height={5}' format: {id. x. y. width. height} :: print."
		
		window := windows detect: [ :w | w morphId = id ].
		window ifNotNil: [
			window morphPosition: x@y.
			window morphExtent: width@height.
		].
		
		line := stream nextLine.
	].

	'restored window positions and locations described in ', fileName :: print.! !

!SystemWindow class methodsFor: '*WindowManager' stamp: 'RMV 12/13/2024 11:23:33'!
saveWindows
	"Write the id, location, and extent of each visible window to a file."
	| fileEntry fileName windows |

	fileName := 'windows.txt'.
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

	'wrote window positions and sizes to ', fileName :: print.! !
