PARAMETER targetNumber IS -1.
PARAMETER clear IS FALSE.

SET SAVEFILE TO "waytargets.txt".



IF exists(SAVEFILE) {
  deletepath(SAVEFILE).
}.
create(SAVEFILE).

LIST targets in alltargets.
SET i TO 0.
FOR target in alltargets {
  log i:tostring + ". " + target:name + "," + target:body:name TO SAVEFILE.   
  SET i TO i+1 .
}.
PRINT "---------------------------------".
PRINT "Saved result to " + SAVEFILE.


IF targetNumber <> -1 {
  IF clear {
    clearvecdraws().
  }.
  vecdraw(V(0,0,0), alltargets[targetNumber]:position, Red, alltargets[targetNumber]:name, 1.0, TRUE).
  PRINT "Also drawn vector. See it on map view.".
}.

PRINT "---------------------------------".
