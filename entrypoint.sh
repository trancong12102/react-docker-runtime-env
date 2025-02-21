#!/usr/bin/env sh

# env path
env_path=$ENV_PATH
# test if env_path is provided
if [ -z "$env_path" ]; then
  echo "env_path is not provided"
  exit 1
fi

# dist path
dist_path=$DIST_PATH
# test if dist_path is provided
if [ -z "$dist_path" ]; then
  echo "dist_path is not provided"
  exit 1
fi

# find all js files in dist
js_files=$(find $dist_path -type f -name "*.js" -not -path "*/node_modules/*")

# get all runtime env variable lines from env_path
env_runtime_lines=$(awk '/### RUNTIME ###/ {getline; if($0 ~ /=/) print}' "$env_path")

# loop through all runtime env variable lines
for line in $env_runtime_lines; do
  env_name=$(echo "$line" | cut -d '=' -f 1)
  env_value=$(echo "$line" | cut -d '=' -f 2 | sed 's/\s*#.*//')
  env_value=$(echo "$env_value" | sed 's/^"\([^"]*\)"$/\1/; s/^'\''\([^'\'']*\)'\''$/\1/')
  runtime_value=$(printenv "$env_name")

  # skip if runtime value is empty
  [ -z "$runtime_value" ] && continue

  echo "Replacing $env_value with $runtime_value in all js files"

  changed_count=0
  # loop through all js files
  for js_file in $js_files; do
    if grep -q "$env_value" "$js_file"; then
      sed -i "s,$env_value,$runtime_value,g" "$js_file"
      changed_count=$((changed_count + 1))
    fi
  done

  if [ "$changed_count" -gt 0 ]; then
    echo "Updated $changed_count files for $env_name"
  fi
done

exec "$@"
