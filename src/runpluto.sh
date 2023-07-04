#!/bin/bash
__usage="
Usage: $(basename $0) [PORT]
Note: you probably want to edit the command variable below.

Options:
  PORT                         Port in which to run pluto. Passed by init.
"


command="
import Pluto;
Pluto.run(
    host=\"0.0.0.0\",
    port=${1},
    launch_browser=false,
    require_secret_for_open_links=false,
    require_secret_for_access=false
)"
echo ${command}
julia --project="/home/jovyan" --optimize=0 -e "${command}"
