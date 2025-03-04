# Cuis-Smalltalk-WindowManager

This package adds four menu items to the World menu.
These address two issues.

The first issue is that by default new windows are opened
near the corners of the Cuis window.
This means that windows can be opened far from the
position that was clicked to open the World menu.
This is especially true when working on a large monitor.

In the Preferences menu this package adds:

- "Open windows near world corners"

  This is the default behavior where windows are opened
  near the four corners of the World, starting near the upper-left.

- "Open windows at cursor location"

  This opens windows so their upper-left corner is at the cursor location.
  If this causes the window to
  extend past the right or bottom edge of the World,
  the window is moved left and/or up so it does not do that.

The second issue is related to window sizes and locations.
When opening a previously saved Cuis image on a laptop,
it opens on the laptop screen.
Suppose you move the Cuis window to an external monitor,
resize the window to fill the entire screen, and
carefully position and resize each window within the Cuis window
to utilize the space.
If you save the image, quit, and restart it,
the Cuis window will once again open on the laptop screen.
The positions of all the windows inside the Cuis window
will be modified to fit on the smaller screen.
If you then move the Cuis window back to the external monitor,
all the work you did to reposition and resize the windows will have been lost.

In the Windows menu this package adds:

- "Save window locations & sizes"

  This writes the id, name, position, and size of
  all the currently open windows to a text file whose
  name is the image name and whose file extension is ".windows".

- "Restore window locations & sizes"

  This reads the ".windows" file for the current image
  and restores the position and size of all the windows
  described in the file.

<video controls width="250">
  <source src="https://mvolkmann.github.io/assets/Cuis-Smalltalk-WindowManager.mov" type="video/mov" />
</video>
