
.PHONY: dashboards
dashboards: # genereate the linkerd2 dashboards for Grafana
		@mkdir -p dashboards_output
		jsonnet -J vendor -m dashboards_output lib/dashboards.jsonnet
