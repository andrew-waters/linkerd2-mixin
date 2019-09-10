
.PHONY: dashboards
dashboards: # genereate the linkerd2 dashboards for Grafana
		@mkdir -p dashboards
		jsonnet -J vendor -m dashboards lib/dashboards.jsonnet
