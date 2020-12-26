// Beep.ks
//   Make noise first
//   Make a noise on program end

SET V0 TO GETVOICE(0). // Gets a reference to the zero-th voice in the chip.
V0:PLAY( NOTE(400, 1.0) ).  // Starts a note at 400 Hz for 2.5 seconds.
                            // The note will play while the program continues.
PRINT "The note is still playing".
PRINT "when this prints out.".