#!/bin/bash
set -e

PLATFORM=$(uname | tr [:upper:] [:lower:])
GIT_REF=$(git describe --tags --always)
SOURCE_DIR=$(git rev-parse --show-toplevel)
VERSION=${GIT_REF}
REVISION=$(git rev-parse --short HEAD)

export PATH="${GOPATH}/bin:${PATH}"
export CGO_ENABLED=0

function license_check {
    retval=0
    for source_file in $(find . -type f -name '*.go' -not -path './examples/**' -not -path './vendor/**'); do
        if ! grep -E 'Copyright [0-9]{4} Mesosphere, Inc.' $source_file &> /dev/null; then
            echo "Missing copyright statement in ${source_file}"
            retval=$((retval + 1))
        fi
        if ! grep 'Licensed under the Apache License, Version 2.0 (the "License");' $source_file &> /dev/null; then
            echo "Missing license header in ${source_file}"
            retval=$((retval + 1))
        fi
    done
    if [[ $retval -gt 0 ]]; then
        echo
        echo "ERROR: found ${retval} cases of missing copyright statements or license headers."
        return $retval
    fi
}

function build_datadog_plugin {
    go build -a -o ${BUILD_DIR}/dcos-metrics-${COMPONENT}-${GIT_REF} \
    -ldflags "-X github.com/dcos/dcos-metrics/plugins.VERSION=${VERSION}" \
    cmd/datadog/datadog.go
}

function build_prometheus_plugin {
    go build -a -o ${BUILD_DIR}/dcos-metrics-${COMPONENT}-${GIT_REF} \
    -ldflags "-X github.com/dcos/dcos-metrics/plugins.VERSION=${VERSION}" \
    cmd/prometheus/prometheus.go
}

function main {
    COMPONENT="$1"
    BUILD_DIR="${SOURCE_DIR}/build/${COMPONENT}"

    build_${COMPONENT} ${BUILD_DIR}
		tree build/
}

main "$@"
