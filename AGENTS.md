# Agent Notes

This project is used from inside the `safe-ai` container. 
AI agents working here should not try to build, run, start, stop, or otherwise manage containers 
from inside this environment.

If container-level work is needed, create a script for the host system, ask the user to run it there, 
and then inspect the resulting logs or output from inside this workspace.
