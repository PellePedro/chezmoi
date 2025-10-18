function makePatch() {
  # Get the last 10 commits
  local commits
  commits=$(git log --pretty=format:"%H %s" -n 10 | fzf -m --prompt="Select 2 commits: " --header="Select 2 commits and press Enter")

  # Ensure exactly 2 commits are selected
  if [[ $(echo "$commits" | wc -l) -ne 2 ]]; then
    echo "You must select exactly 2 commits."
    return 1
  fi

  # Extract the commit hashes
  local commit1
  local commit2
  commit1=$(echo "$commits" | head -n 1 | awk '{print $1}')
  commit2=$(echo "$commits" | tail -n 1 | awk '{print $1}')

  # Create the patch
  local patch_file="${commit1}_to_${commit2}.patch"
  git diff "$commit1" "$commit2" > "$patch_file"

  echo "Patch created: $patch_file"
}

function sha() { 
    export SHA=$(git rev-parse --short HEAD)
    echo "SHA is : $SHA"
}

function zocat() {
    localhost_port=$1
    host_port=$2
    socat TCP-LISTEN:$host_port,fork TCP:127.0.0.1:$localhost_port
}

function prune() {
    sudo docker system prune -a
}
