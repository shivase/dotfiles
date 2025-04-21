#!/bin/bash
ps aux | grep '/bin/zsh' | grep -v grep | awk '{print $2}' | xargs kill -9

