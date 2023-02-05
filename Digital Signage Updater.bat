::This was a fun script that I made to speed up transfering media files to numerous Digital Signage TV's around the office
::To create the digital signage solution on a budget, I leveraged a combination of Intel Compute Sticks and scripts. 
::Each TV around the office had an Intel Compute stick attached to it with a script to launch Chrome on boot in full screen. 
::The Chrome instance had an extension called Rotisserie which would cycle through a list of URLs
::These URL's were local file locations of video files, and photos. 
::Being that the company I was working for created games, we would load the recent trailer videos onto the TV's
::In addition to the trailers, I would create infographic photos to display company information in between trailers. 
::
::
@ECHO off
COLOR 0A
echo -------------------------------------------------------------------------------
echo                         Digital Signage Updater Script 
echo                                   v4.0
echo -------------------------------------------------------------------------------
ECHO.
ECHO.
::This is the menu where you would select which info needed updating. 
goto :MenuSelect
:MenuSelect
echo What do you want to update
echo.
echo 1: Game Trailers
echo 2: Info Screens
echo 3: AppTweak Graphs 
echo 4: Both
echo.
set /p Option= Please select option from above:  

if %Option%==1 goto :TrailerUpdater
if %Option%==2 goto :InfoUpdater
if %Option%==3 goto :AppTweak
if %Option%==4 goto :TrailerUpdater

::These transfer sections would have numerous robocopy blocks, one for each Compute Stick.  
:TrailerUpdater
echo -------------------------------------------------------------------------------
echo                        Starting Transfer to Computer 1
echo -------------------------------------------------------------------------------
robocopy \\\Network\Path\With\TV_Media\Screens \\Intel\Compute\Stick\Media\Trailers /TEE /MIR /w:1 /r:2 /xo 
echo -------------------------------------------------------------------------------
echo                         Transfer to Computer 1 Complete
echo -------------------------------------------------------------------------------
ECHO.
if %Option%==4 goto :InfoUpdater
if %Option%==1 goto :Finished

:InfoUpdater
echo -------------------------------------------------------------------------------
echo                          Starting Transfer to Computer 1
echo -------------------------------------------------------------------------------
robocopy \\\Network\Path\With\TV_Media\Screens \\Intel\Compute\Stick\Media\Screens /TEE /MIR /w:1 /r:2 /xo 
echo -------------------------------------------------------------------------------
echo                          Transfer to Computer 1 Complete
echo -------------------------------------------------------------------------------
ECHO.
if %Option%==4 goto :AppTweak
if %Option%==2 goto :Finished

:AppTweak
echo -------------------------------------------------------------------------------
echo                         Starting Transfer to Computer 1
echo -------------------------------------------------------------------------------
robocopy \\\Network\Path\With\TV_Media\Screens \\Intel\Compute\Stick\Media\AppTweak /TEE /MIR /w:1 /r:2 /xo 
echo -------------------------------------------------------------------------------
echo                         Transfer to Computer 1 Complete
echo -------------------------------------------------------------------------------
goto :Finished

:Finished
echo -------------------------------------------------------------------------------
echo                      All TV's Have Been Updated. . . 100%%
echo -------------------------------------------------------------------------------
pause