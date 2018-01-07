@VERIFY other 2>nul
@SETLOCAL EnableDelayedExpansion
@IF ERRORLEVEL 1 (
    @ECHO Unable to enable extensions
    @GOTO failure
)

@REM Connect up the current ssh-agent
@ECHO Removing old ssh-agent sockets
@FOR /d %%d IN (%TEMP%\ssh-??????*) DO @RMDIR /s /q %%d

@start /WAIT my-start-ssh-agent.bat

@pause 2

:ssh_agent_pid
@FOR /f "tokens=1-2" %%a IN ('tasklist /fi "imagename eq ssh-agent.exe"') DO @(
    @ECHO %%b | @FINDSTR /r /c:"[0-9][0-9]*" > NUL
    @IF "!ERRORLEVEL!" == "0" @(
        @SET SSH_AGENT_PID=%%b
    ) else @(
        @REM Unset in the case a user kills the agent while a session is open
        @REM needed to remove the old files and prevent a false message
        @SET SSH_AGENT_PID=
    )
)
@IF [!SSH_AGENT_PID!] == []  @(
    @GOTO ssh_agent_pid
)
@ECHO Found ssh-agent at !SSH_AGENT_PID!
@FOR /d %%d IN (%TEMP%\ssh-??????*) DO @(
    @FOR %%f IN (%%d\agent.*) DO @(
        @SET SSH_AUTH_SOCK=%%f
        @SET SSH_AUTH_SOCK=!SSH_AUTH_SOCK:%TEMP%=/tmp!
        @SET SSH_AUTH_SOCK=!SSH_AUTH_SOCK:\=/!
    )
)
@IF NOT [!SSH_AUTH_SOCK!] == [] @(
    @ECHO Found ssh-agent socket at !SSH_AUTH_SOCK!
) ELSE (
    @ECHO Failed to find ssh-agent socket
)

@REM See if we have the key
@SET "HOME=%USERPROFILE%"
@call C:\tools\cmder\vendor\git-for-windows\usr\bin\ssh-add.exe
@REM @"!SSH_ADD!" -l 1>NUL 2>NUL
@REM @SET result=!ERRORLEVEL!
@REM @IF NOT !result! == 0 @(
@REM     @IF !result! == 2 @(
@REM         @ECHO | @SET /p=Starting ssh-agent:
@REM         @FOR /f "tokens=1-2 delims==;" %%a IN ('"!SSH_AGENT!"') DO @(
@REM             @IF NOT [%%b] == [] @SET %%a=%%b
@REM         )
@REM         @ECHO. done
@REM     )
    @REM @ECHO.
@REM )


@REM call start-ssh-agent

@del C:\tools\cmder\bin\ssh-agent-setter.bat

echo @SETX /m SSH_AGENT_PID %SSH_AGENT_PID%>C:\tools\cmder\bin\ssh-agent-setter.bat
echo @SETX /m SSH_AUTH_SOCK %SSH_AUTH_SOCK%>>C:\tools\cmder\bin\ssh-agent-setter.bat

@start  C:\tools\cmder\bin\my-ssh-agent-setter.bat
	  
:failure
@ENDLOCAL

@ECHO %cmdcmdline% | @FINDSTR /l "\"\"" >NUL
@IF NOT ERRORLEVEL 1 @(
    @CALL cmd %*
)
