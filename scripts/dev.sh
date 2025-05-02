#!/usr/bin/env bash

handle_docker_project() {
  local project=$1
  local project_dir=$2
  local url=$4
  local compose_file=$5

  local compose_cmd="docker-compose"
  if [ "$compose_file" != "" ]; then
    compose_cmd="docker-compose -f $compose_file"
  fi

  echo "Managing $project (Docker Compose)"
  action=$(gum filter "Open URL" "Start services" "Rebuild and start services" "Restart services" "Stop services" "Status" "View logs" "Back")

  case "$action" in
  "Open URL")
    echo "Opening $url"
    open "$url"
    exit 0
    ;;
  "Start services")
    echo "Starting Docker Compose services for $project"
    cd "$project_dir" && "$compose_cmd" up -d
    exit 0
    ;;
  "Rebuild and start services")
    echo "Restarting Docker Compose services for $project"
    cd "$project_dir" && "$compose_cmd" up -d --build --force-recreate
    exit 0
    ;;
  "Restart services")
    echo "Restarting Docker Compose services for $project"
    cd "$project_dir" && "$compose_cmd" restart
    exit 0
    ;;
  "Stop services")
    echo "Stopping Docker Compose services for $project"
    cd "$project_dir" && "$compose_cmd" down
    exit 0
    ;;
  "Status")
    echo "Checking status of Docker Compose services for $project"
    cd "$project_dir" && "$compose_cmd" ps -a
    exit 0
    ;;
  "View logs")
    echo "Viewing logs for $project"
    cd "$project_dir" && "$compose_cmd" logs
    exit 0
    ;;
  "Back")
    main
    ;;
  esac
}

handle_regular_project() {
  local project=$1
  local url=$2
  local start_cmd=$3

  echo "Managing $project"
  action=$(gum filter "Open URL" "Start application" "Stop application" "Back")

  case "$action" in
  "Open URL")
    echo "Opening $url"
    open "$url"
    ;;
  "Start application")
    echo "Starting $project"
    eval "$start_cmd"
    exit 0
    ;;
  "Stop application")
    echo "Stopping $project"
    echo "Not implemented yet"
    exit 0
    ;;
  "Back")
    main
    ;;
  esac
}

main() {
  choice=$(gum filter "Nadace" "Spokojenost" "Decision rule" "AkceLeto" "Otik" "NutriTrack" "Quit")

  if [ "$choice" = "" ]; then
    echo "No choice made, exiting..."
    exit 0
  fi

  case "$choice" in
  "Nadace")
    handle_docker_project "Nadace" "$HOME/.local/projects/work/o2-foundation-forms" "app" "http://localhost:8888" ".docker/dev/docker-compose.yml"
    ;;
  "Spokojenost")
    handle_regular_project "Spokojenost" "http://localhost:8080" "cd /path/to/spokojenost && npm start"
    ;;
  "Decision rule")
    handle_docker_project "Decision rule" "/path/to/decision-rule" "api" "http://localhost:5000" "docker-compose.prod.yml"
    ;;
  "AkceLeto")
    handle_docker_project "AkceLeto" "$HOME/.local/projects/work/akceleto2020" "web" "http://localhost:8998" "docker/docker-compose.yml"
    ;;
  "Otik")
    handle_docker_project "Otik" "$HOME/.local/projects/work/evidence-prodejcu" "web" "http://localhost:8988/www" "docker/docker-compose.yml"
    ;;
  "NutriTrack")
    handle_regular_project "NutriTrack" "http://localhost:3000" "cd $HOME/.local/projects/personal/nutri-track && pnpm dev"
    ;;
  "Quit")
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
  esac
}

main
