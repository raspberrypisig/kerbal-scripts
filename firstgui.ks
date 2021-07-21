set defaultLat to 37 .
set defaultLong to -145.1 .

//--------------------------Start Dialog Box--------------------------------------------
function start_dialog {
  set gui to GUI(300).
  //SET gui:x TO 30.
  //SET gui:y TO 100.
  local labelIntro to gui:addlabel("<size=20><b>Enter Details below. </b></size>").
  set labelIntro:style:align to "CENTER".
  set labelIntro:style:hstretch to True. 
  local vbox to gui:addvbox().
  local firsthlayout to vbox:addhlayout().
  local eastlatlabel to firsthlayout:addlabel("Lat").
  local eastlattextfield to firsthlayout:addtextfield("").
  local eastlonglabel to firsthlayout:addlabel("Long").
  local eastlongtextfield to firsthlayout:addtextfield("").
  local ok to gui:addbutton("OK").
  set ok:onclick to {
    set isDone to true. 
  }.
  gui:show().
  set isDone to false.
  wait until isDone.
  set userLat to eastlattextfield:text:tonumber(defaultLat).
  set userLong to eastlongtextfield:text:tonumber(defaultLong).
}

start_dialog().
gui:hide(). 
set east_ves to latlng(userLat, userLong).
print "Lat:" + userLat .
print "Long:" + userLong .
print "Ves:" + east_ves .