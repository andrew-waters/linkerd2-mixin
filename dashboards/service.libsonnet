local g = import 'grafonnet/grafana.libsonnet';
local common = import 'common.libsonnet';
local dashboard = g.dashboard;
local row = g.row;
local prometheus = g.prometheus;
local template = g.template;
local singlestat = g.singlestat;

{

  dashboards+:: {
    'service.json':
      local namespacesMonitored =
        singlestat.new(
          $.linkerd.titles['service']['namespacesMonitored'],
          datasource='%(datasource)s' % $.linkerd.datasource,
          span=2,
          valueName='current',
        )
        .addTarget(prometheus.target('count(count(request_total{namespace=~\"$namespace\"}) by (namespace))' % $.linkerd));

      dashboard.new(
        '%(namePrefix)sService' % $.linkerd.dashboard,
        time_from='now-5m',
        uid=($.linkerd.dashboardIDs['service.json']),
        tags=($.linkerd.dashboard.tags),
        editable=($.linkerd.dashboard.editable),
      )
      .addTemplate(
        common.cluster($.linkerd.datasource, $.linkerd.multiCluster.enabled, $.linkerd.multiCluster.label, $.linkerd.multiCluster.labelName),
      )
      .addTemplate(
        common.namespace($.linkerd.datasource, true),
      )
      .addRow(
        row.new()
        .addPanel(namespacesMonitored)
      ),
  },
}
