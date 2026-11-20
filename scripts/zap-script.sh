#!/bin/bash
set -euo pipefail

zap_dir="$(mktemp -d)"
chmod a+rwx "$zap_dir"

cat > "$zap_dir/plan.yaml" <<'YAML'
env:
  contexts:
    - name: workshop-pages
      urls:
        - https://1220571568.github.io/bitcoin-order-app/
jobs:
  - type: passiveScan-config
    parameters:
      scanOnlyInScope: true
  - type: requestor
    requests:
      - url: https://1220571568.github.io/bitcoin-order-app/
        method: GET
        responseCode: 200
  - type: passiveScan-wait
  - type: report
    parameters:
      template: traditional-html
      reportDir: /zap/wrk
      reportFile: zap_baseline_report.html
      reportTitle: Workshop DAST - Passive Homepage Check
YAML

docker run --rm -v "$zap_dir:/zap/wrk:rw" \
  ghcr.io/zaproxy/zaproxy:stable \
  zap.sh -cmd -autorun /zap/wrk/plan.yaml

cp "$zap_dir/zap_baseline_report.html" ./zap_baseline_report.html