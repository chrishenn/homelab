#!/bin/bash

session="new"
tmux new-session -d -s ${session}
window=${session}:0
pane=${window}.0
tmux send-keys -t "$pane" 'conda activate env39' Enter
tmux send-keys -t "$pane" 'python -m visdom.server' Enter

sleep 6

xdg-open "http://localhost:8097" &
disown
