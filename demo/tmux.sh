#!/bin/bash

session=clustor
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

cd $root/app

tmux start-server
tmux new-session -d -s "$session" -n "app1"

for i in {2..3}; do
  tmux new-window -t "$session:$i" -n "app$i"
done

for i in {1..3}; do
  sleep 0.2
  tmux send-keys -t "$session:$i" "mix deps.get; source ../env/app$i; iex -S mix" C-m
done

tmux attach -t $session

# Kill this tmux session as follows
#
#   tmux kill-session -t clustor
#
