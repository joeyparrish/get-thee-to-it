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

# The delete command implementation.
# Assumes that lib.sh has been loaded and all required variables are set.

if ! check_permissions; then
  reply "Only maintainers may delete links."
  exit 0
fi

if [[ ${#BOT_ARGUMENTS[@]} -ne 1 ]]; then
  (
    echo "Bad link syntax: \`${BOT_ARGUMENTS[@]}\`."
    echo ""
    echo "You must use the form \`/bot delete foo\`."
  ) | reply_from_pipe
  exit 0
fi

short_name="${BOT_ARGUMENTS[0]}"
url="${BOT_ARGUMENTS[2]}"

if [[ -e "$GITHUB_WORKSPACE/$short_name/index.html" ]]; then
  reply "Short link \`$short_name\` not found."
else
  (
    set -e
    git rm -rf "$GITHUB_WORKSPACE/$short_name/"
    git commit -m "Delete $short_name"
    git push
  ) && reply "Short link \`$short_name\` deleted." || reply "Failed to delete short link \`$short_name\`\!"
fi
