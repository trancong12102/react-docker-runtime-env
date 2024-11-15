#!/usr/bin/env sh

# env path
env_path=$(pwd)/.env.production

# dist path
dist_path=$(pwd)

# get all env variable names from env_path (skip empty lines, comments)
env_names=$(grep -v '^\s*$\|^\s*#' $env_path | cut -d '=' -f 1)
echo "Found env names: $env_names"

# find all js files in dist
js_files=$(find $dist_path -type f -name "*.js")
echo "Found js files: $js_files"

# loop through all js files
for js_file in $js_files; do
  echo "Processing $js_file"

  # loop through all env names
  for env_name in $env_names; do
    env_name=$env_prefix$env_name
    # get env value by env name from runtime env
    env_value=$(printenv $env_name)
    echo "Found env value: $env_value"

    # skip if env value is empty
    if [ -z "$env_value" ]; then
      echo "Skip $env_name"
      continue
    fi

    # replace string "$env_name" with "$env_value" in js file
    sed -i "s/$env_name/$env_value/g" $js_file
  done
done

exec "$@"
