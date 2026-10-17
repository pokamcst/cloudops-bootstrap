#!/bin/bash
echo "=== DevOps Tools Verification ==="
echo ""
for cmd in terraform kubectl helm az k9s kubectx kubens kubelogin yq jq; do
  if command -v "$cmd" &>/dev/null; then
    ver=$("$cmd" --version 2>&1 | head -1)
    printf "  %-12s ✅  %s\n" "$cmd" "$ver"
  else
    printf "  %-12s ❌  NOT FOUND\n" "$cmd"
  fi
done
echo ""
echo "Done."
