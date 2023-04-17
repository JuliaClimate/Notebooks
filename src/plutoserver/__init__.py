import os


def setup_plutoserver():
    mydir = os.path.dirname(os.path.realpath(__file__))
    iconpath = os.path.join(mydir, "icons", "pluto-logo.svg")
    return {
        "command": ["/bin/bash", "/usr/local/etc/gf/runpluto.sh", "{port}"],
        "timeout": 120,
        "launcher_entry": {"title": "Pluto.jl", "icon_path": iconpath},
    }
