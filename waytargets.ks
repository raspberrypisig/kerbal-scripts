SET SAVEFILE TO "waytargets.txt".

IF exists(SAVEFILE) {
  deletepath(SAVEFILE).
}.
create(SAVEFILE).

LIST targets in alltargets.
SET i TO 0.
FOR target in alltargets {
  PRINT target:name.
  log i:tostring + ". " + target:name TO SAVEFILE.   
  SET i TO i+1 .
}.

