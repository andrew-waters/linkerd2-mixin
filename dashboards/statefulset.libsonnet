local g = import 'grafonnet/grafana.libsonnet';
local common = import 'common.libsonnet';
local dashboard = g.dashboard;
local row = g.row;
local prometheus = g.prometheus;
local template = g.template;
local singlestat = g.singlestat;

{

  grafanaDashboards+:: {
    'statefulset.json':
      local namespacesMonitored =
        singlestat.new(
          $._config.titles['statefulset']['namespacesMonitored'],
          datasource='%(datasource)s' % $._config.datasource,
          span=2,
          valueName='current',
        )
        .addTarget(prometheus.target('count(count(request_total{namespace=~\"$namespace\"}) by (namespace))' % $._config));

      dashboard.new(
        '%(dashboardNamePrefix)sStatefulSet' % $._config.meta,
        time_from='now-5m',
        uid=($._config.dashboardIDs['statefulset.json']),
        tags=($._config.meta.dashboardTags),
        editable=true,
      )
      .addTemplate(
        common.cluster($._config.datasource, $._config.showMultiCluster, $._config.clusterLabel, $._config.clusterLabelName),
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