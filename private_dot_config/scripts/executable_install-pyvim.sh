#!/bin/bash

uv venv --python 3.12 $HOME/.local/venv
source $HOME/.local/venv/bin/activate
uv pip install codespell
deactivate
