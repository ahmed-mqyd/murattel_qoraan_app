#!/bin/bash
#
# Fetches Dart packages for a Claude Code cloud session.
#
# The Flutter SDK itself comes from the environment's setup script; this only
# resolves the project's own dependencies. Local sessions already have them.

set -u

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/..}" || exit 0

flutter pub get || true

exit 0
