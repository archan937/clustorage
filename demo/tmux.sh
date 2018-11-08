#!/bin/bash

session=clustor
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

tmux start-server

cd $root/app1
tmux new-session -d -s "$session" -n "app1"

for i in {2..3}; do
  cd $root/app$i
  tmux new-window -t "$session:$i" -n "app$i"
done

for i in {1..3}; do
  tmux send-keys -t "$session:$i" "mix deps.get; iex -S mix" C-m
done

tmux attach -t $session

# Kill this tmux session as follows
#
#   tmux kill-session -t clustor
#
