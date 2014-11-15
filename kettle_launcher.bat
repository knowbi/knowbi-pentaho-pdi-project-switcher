@echo off
setlocal enabledelayedexpansion

set KETTLE_D=%CD%\Kettle
set CURRENT_DIR=%CD%
set USER_DIR=%UserProfile%


set /A COUNTER=0
set /A COUNTER2=0


echo Projects
echo -----------------------
echo.
FOR /D %%i in (*.*) DO (
	IF NOT %%i==Kettle (
		set /A COUNTER+=1
		echo !COUNTER!: %%i
		set PROJECTLIST[!COUNTER!]=%%i
	)
)
IF %COUNTER%==0 (
	echo ERROR:No Projects found!
	pause
	exit
)

set /p PROJECTNUM="Choose Project:" %=%
echo.
set PROJECTNAME=!PROJECTLIST[%PROJECTNUM%]!


IF EXIST .\%PROJECTNAME%\config.cfg ( 
	FOR /F "tokens=1* delims==" %%i IN (.\%PROJECTNAME%\config.cfg) DO set "prop_%%i=%%j"
	set PROJECT_DIR=%CURRENT_DIR%\%PROJECTNAME%
	echo kettle version: !prop_KETTLE_VERSION!
	goTo:launch
) ELSE (
	cd "%PROJECTNAME%"

	echo Subprojecs/Environment
	echo -----------------------
	echo.

	FOR /D %%i in (*.*) DO (
		IF NOT %%i==Kettle (
			set /A COUNTER2+=1
			echo !COUNTER2!: %%i
			set ENVLIST[!COUNTER2!]=%%i
		)
	)
)
IF %COUNTER2%==0 (
	echo ERROR:No Environments found!
	pause
	exit
)

set /p ENVNUM="Choose Environment:" %=%
echo.
set ENVNAME=!ENVLIST[%ENVNUM%]!

IF EXIST .\%ENVNAME%\config.cfg ( 
	FOR /F "tokens=1* delims==" %%i IN (.\%ENVNAME%\config.cfg) DO set "prop_%%i=%%j"
	set PROJECT_DIR=%CURRENT_DIR%\%PROJECTNAME%/%ENVNAME%
	echo kettle version: !prop_KETTLE_VERSION!
) ELSE (
	echo "ERROR: Not a Valid project/environment (is there a config.cfg file ?)"
)


:launch
IF DEFINED prop_KETTLE_VERSION (	
	
	set KETTLE_HOME=%PROJECT_DIR%

	
	IF EXIST %KETTLE_D%\%prop_KETTLE_VERSION% (
		IF EXIST %PROJECT_DIR%\jdbc.properties (
			copy /y "%PROJECT_DIR%\jdbc.properties" "%KETTLE_D%\%prop_KETTLE_VERSION%\simple-jndi\jdbc.properties"
		) ELSE (
			echo INFO: no JDBC file found creating empty file
			IF EXIST "%KETTLE_D%\%prop_KETTLE_VERSION%\simple-jndi\jdbc.properties" (
				del /Q "%KETTLE_D%\%prop_KETTLE_VERSION%\simple-jndi\jdbc.properties"
				copy /y NUL "%KETTLE_D%\%prop_KETTLE_VERSION%\simple-jndi\jdbc.properties"
				)
		)
		IF EXIST %PROJECT_DIR%\pwd (
			del /Q "%KETTLE_D%\%prop_KETTLE_VERSION%\pwd"
			copy /y "%PROJECT_DIR%\pwd" "%KETTLE_D%\%prop_KETTLE_VERSION%\pwd"
		) ELSE (
			echo INFO: no Carte configuration found will use what is present in kettle directory
		)
	
		CD %KETTLE_D%\%prop_KETTLE_VERSION%\
		CALL spoon.bat
	) ELSE (
		echo ERROR: The specified kettle version %prop_KETTLE_VERSION% does not exist in the Kettle folder
	)

) ELSE (
	echo ERROR: no KETTLE_VERSION specified in config.cfg
)
