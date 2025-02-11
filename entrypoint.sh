#!/usr/bin/env sh

# env path
env_path=$(pwd)/.env.production

# dist path
dist_path=$(pwd)

# find all js files in dist
js_files=$(find $dist_path -type f -name "*.js")

# get all runtime env variable lines from env_path
env_runtime_lines=$(awk '/### RUNTIME ###/ {getline; if($0 ~ /=/) print}' "$env_path")

# loop through all runtime env variable lines
for line in $env_runtime_lines; do
  env_name=$(echo "$line" | cut -d '=' -f 1)
  env_value=$(echo "$line" | cut -d '=' -f 2 | sed 's/\s*#.*//')
  runtime_value=$(printenv "$env_name")

  echo "env_name: $env_name"
  echo "env_value: $env_value"

  # skip if runtime value is empty
  [ -z "$runtime_value" ] && continue

  echo "Replacing $env_value with $runtime_value in all js files"

  # loop through all js files
  for js_file in $js_files; do
    $() sed -i "s,$env_value,$runtime_value,g" "$js_file"
    echo "Replaced $env_value with $runtime_value in $js_file"
  done
done

exec "$@"
