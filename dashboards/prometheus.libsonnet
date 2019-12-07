local g = import 'grafonnet/grafana.libsonnet';
local common = import 'common.libsonnet';
local dashboard = g.dashboard;
local row = g.row;
local prometheus = g.prometheus;
local template = g.template;
local singlestat = g.singlestat;

{

  grafanaDashboards+:: {
    'prometheus.json':
      local namespacesMonitored =
        singlestat.new(
          $._config.titles['prometheus']['namespacesMonitored'],
          datasource='%(datasource)s' % $._config.datasource,
          span=2,
          valueName='current',
        )
        .addTarget(prometheus.target('count(count(request_total{namespace=~\"$namespace\"}) by (namespace))' % $._config));

      dashboard.new(
        '%(namePrefix)sPrometheus' % $._config.dashboard,
        time_from='now-5m',
        uid=($._config.dashboardIDs['prometheus.json']),
        tags=($._config.dashboard.tags),
        editable=true,
      )
      .addTemplate(
        common.cluster($._config.datasource, $._config.multiCluster.enabled, $._config.multiCluster.label, $._config.multiCluster.labelName),
      )
      .addTemplate(
        common.namespace($._config.datasource, true),
      )
      .addRow(
        row.new()
        .addPanel(namespacesMonitored)
      ),
  },
}
