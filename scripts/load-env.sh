#!/usr/bin/env zsh

load-env () {
  if [ $# -eq 0 ]; then
      echo "Usage: $0 <env_file>"
      exit 1
  fi

  env_file="$1"

  if [ ! -f "$env_file" ]; then
      echo "Environment file not found: $env_file"
      exit 1
  fi

  while IFS='=' read -r key value
  do
    if [[ ! $key =~ ^# && -n $key ]]; then
      key=$(echo "$key" | xargs)
      value=$(echo "$value" | xargs)
      export "$key=$value"
    fi
  done < "$env_file"
}
