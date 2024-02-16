# Copyright 2024 Joey Parrish
#
# Licensed under the MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# The link command implementation.
# Assumes that lib.sh has been loaded and all required variables are set.

if ! check_permissions; then
  reply "Only maintainers may create links."
  exit 0
fi

if [[ ${#BOT_ARGUMENTS[@]} -ne 3 || ${BOT_ARGUMENTS[1]} != "to" ]]; then
  (
    echo "Bad link syntax: \`${BOT_ARGUMENTS[@]}\`."
    echo ""
    echo "You must use the form \`/bot link foo to https://bar\`."
  ) | reply_from_pipe
  exit 0
fi

short_name="${BOT_ARGUMENTS[0]}"
url="${BOT_ARGUMENTS[2]}"

# See https://unix.stackexchange.com/a/296536
(
  set -e

  mkdir -p "$GITHUB_WORKSPACE/$short_name/"
  cat "$GITHUB_WORKSPACE/template.html" | sed -e "s'{{url}}'$url'" > "$GITHUB_WORKSPACE/$short_name/index.html"

  git config --global user.email "actions-bot@github.com"
  git config --global user.name "GitHub Actions [bot]"

  git add "$GITHUB_WORKSPACE/$short_name/index.html"
  git commit -m "Update $short_name"
  git push
); rv=$?

if [[ $rv == 0 ]]; then
  reply "Short link \`$short_name\` created."
else
  reply "Failed to create short link \`$short_name\`\!"
fi
