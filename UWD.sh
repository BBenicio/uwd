#!/bin/sh
echo -ne '\033c\033]0;UWD\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/UWD.x86_64" "$@"
