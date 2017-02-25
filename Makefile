.PHONY: all build test clean

all: clean build plugin test

build:
	bash -c "./scripts/build.sh datadog_plugin"
	bash -c "./scripts/build.sh prometheus_plugin"

test:
	bash -c "./scripts/test.sh collector unit"

clean:
	rm -rf ./build
	rm -rf ./schema/metrics_schema
