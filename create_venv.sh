#!/bin/bash
IDO_DIR="$(dirname "$0")"
. "$IDO_DIR"/find_cmds.sh
$PYTHON_CMD -m venv "$IDO_DIR/venv"
"$IDO_DIR"/run_in_venv.sh -m pip install "$IDO_DIR/"
