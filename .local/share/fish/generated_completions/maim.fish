# maim
# Autogenerated from man page /usr/share/man/man1/maim.1.gz
complete -c maim -s h -l help -d 'Print help and exit'
complete -c maim -s v -l version -d 'Print version and exit'
complete -c maim -s x -l xdisplay -d 'Sets the xdisplay to use'
complete -c maim -s f -l format -d 'Sets the desired output format, by default maim will attempt to determine the…'
complete -c maim -s i -l window -d 'By default, maim captures the root window'
complete -c maim -s g -l geometry -d 'Sets the region to capture, uses local coordinates from the given window'
complete -c maim -s w -l parent -d 'By default, maim assumes the --geometry values are in respect to the provided…'
complete -c maim -s B -l capturebackground -d 'By default, when capturing a window, maim will ignore anything beneath the sp…'
complete -c maim -s d -l delay -d 'Sets the time in seconds to wait before taking a screenshot'
complete -c maim -s u -l hidecursor -d 'By default maim super-imposes the cursor onto the image, you can disable that…'
complete -c maim -s m -l quality -d 'An integer from 1 to 10 that determines the compression quality'
complete -c maim -s s -l select -d 'Enables an interactive selection mode where you may select the desired region…'
complete -c maim -s b -l bordersize -d 'Sets the selection rectangle\'s thickness'
complete -c maim -s p -l padding -d 'Sets the padding size for the selection, this can be negative'
complete -c maim -s t -l tolerance -d 'How far in pixels the mouse can move after clicking, and still be detected as…'
complete -c maim -s c -l color -d 'Sets the selection rectangle\'s color.  Supports RGB or RGBA input'
complete -c maim -s r -l shader -d 'This sets the vertex shader, and fragment shader combo to use when drawing th…'
complete -c maim -s n -l nodecorations -d 'Sets the level of aggressiveness when trying to remove window decorations'
complete -c maim -s l -l highlight -d 'Instead of outlining a selection, maim will highlight it instead'
complete -c maim -s D -l nodrag -d 'Allows you to click twice to indicate a selection, rather than click-dragging'
complete -c maim -s q -l quiet -d 'Disable any unnecessary cerr output.  Any warnings or info simply won\'t print'
complete -c maim -s k -l nokeyboard -d 'Disables the ability to cancel selections with the keyboard'
complete -c maim -s o -l noopengl -d 'Disables graphics hardware acceleration'
