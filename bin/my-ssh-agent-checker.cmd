call start-ssh-agent

@del C:\tools\cmder\bin\ssh-agent-setter.bat

echo @SETX /m SSH_AGENT_PID %SSH_AGENT_PID%>C:\tools\cmder\bin\ssh-agent-setter.bat
echo @SETX /m SSH_AUTH_SOCK %SSH_AUTH_SOCK%>>C:\tools\cmder\bin\ssh-agent-setter.bat

@start  C:\tools\cmder\bin\my-ssh-agent-setter.bat
	  
