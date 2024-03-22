#!/usr/bin/env nu

def main [args: string] {
  xdg-open $args out+err> /dev/null
}
