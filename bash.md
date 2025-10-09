# Bash Hints

## Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Define variables if not defined
: ${SKYRAMPDIR:=$HOME/git/dev}
: ${SKYRAMP:=$SKYRAMPDIR/bin/skyramp}

## String manipulation
# Get string length
${#variable}

# Substring extraction
${variable:offset:length}
${variable:offset}  # from offset to end

# String replacement
${variable/pattern/replacement}   # replace first match
${variable//pattern/replacement}  # replace all matches

# Remove prefix/suffix
${variable#pattern}   # remove shortest match from beginning
${variable##pattern}  # remove longest match from beginning
${variable%pattern}   # remove shortest match from end
${variable%%pattern}  # remove longest match from end

## Array operations
# Declare array
declare -a my_array=("item1" "item2" "item3")

# Access elements
${my_array[0]}     # first element
${my_array[@]}     # all elements
${#my_array[@]}    # array length

# Loop through array
for item in "${my_array[@]}"; do
    echo "$item"
done

## Conditionals
# File tests
[ -f file ]    # file exists and is regular file
[ -d dir ]     # directory exists
[ -e path ]    # path exists
[ -r file ]    # file is readable
[ -w file ]    # file is writable
[ -x file ]    # file is executable
[ -s file ]    # file exists and is not empty

# String tests
[ -z "$var" ]  # string is empty
[ -n "$var" ]  # string is not empty
[ "$a" = "$b" ]   # strings are equal
[ "$a" != "$b" ]  # strings are not equal

# Numeric tests
[ "$a" -eq "$b" ]  # equal
[ "$a" -ne "$b" ]  # not equal
[ "$a" -lt "$b" ]  # less than
[ "$a" -le "$b" ]  # less than or equal
[ "$a" -gt "$b" ]  # greater than
[ "$a" -ge "$b" ]  # greater than or equal

## Command execution
# Run command and capture output
output=$(command)

# Run command in background
command &

# Redirect stderr to stdout
command 2>&1

# Redirect both to file
command &> file

# Pipe stderr only
command 2>&1 >/dev/null | grep error

## Exit on error
set -e  # exit on error
set -u  # exit on undefined variable
set -o pipefail  # exit on pipe failure
set -euo pipefail  # all of the above

## Functions
my_function() {
    local arg1="$1"
    local arg2="${2:-default}"  # with default value
    echo "arg1: $arg1, arg2: $arg2"
    return 0
}

## Parameter expansion with defaults
${var:-default}   # use default if var is unset or empty
${var:=default}   # assign default if var is unset or empty
${var:?error}     # display error if var is unset or empty
${var:+alternate} # use alternate if var is set

## Here documents
cat <<EOF
Multi-line
text here
EOF

# With variable substitution disabled
cat <<'EOF'
$variable won't be expanded
EOF

## Process substitution
diff <(command1) <(command2)
while read line; do
    echo "$line"
done < <(command)

## Debugging
set -x  # print commands before executing
set +x  # turn off command printing

## Trap errors and cleanup
cleanup() {
    echo "Cleaning up..."
    # cleanup code here
}
trap cleanup EXIT ERR

## Check if command exists
if command -v foo &> /dev/null; then
    echo "foo is installed"
fi

## Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Usage: $0 [options]"
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        -f|--file)
            FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

## Safe file operations
# Create temp file
tmpfile=$(mktemp)
trap "rm -f $tmpfile" EXIT

# Create temp directory
tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

## Working with JSON (using jq)
# Parse JSON
value=$(echo "$json" | jq -r '.key')

# Create JSON
json=$(jq -n --arg name "value" '{key: $name}')

## Date operations
# Current timestamp
date +%s

# Format date
date +"%Y-%m-%d %H:%M:%S"

# Date arithmetic
date -d "+1 day" +%Y-%m-%d
date -d "2 weeks ago" +%Y-%m-%d

## Find and execute
# Find files and execute command
find . -name "*.txt" -exec grep "pattern" {} +

# Find and delete
find . -name "*.tmp" -delete

## Useful one-liners
# Print nth column
awk '{print $3}'

# Sum numbers in column
awk '{sum+=$1} END {print sum}'

# Remove duplicate lines (preserving order)
awk '!seen[$0]++'

# Count occurrences
sort | uniq -c | sort -rn

# Replace in files recursively
find . -type f -name "*.txt" -exec sed -i 's/old/new/g' {} +
