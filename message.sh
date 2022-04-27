#!/bin/sh

message() {
  CS="\033[1;34;40m"  # color start
  CE="\033[0m"        # color end

  echo -ne "$CS $1 $CE \n"
}
