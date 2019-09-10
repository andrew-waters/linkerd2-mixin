{
  cluster:: function(ds, show, label, name)
    {
      current: {
        text: 'All',
        value: '$__all',
      },
      datasource: ds,
      hide: if show then 0 else 2,
      includeAll: true,
      label: name,
      name: 'cluster',
      options: [],
      query: 'label_values(request_total, cluster)', // $label
      refresh: 2,
      regex: '',
      type: 'query',
      useTags: false,
    },

  namespace:: function(ds, show)
    {
      current: {
        text: 'All',
        value: '$__all',
      },
      datasource: ds,
      hide: if show then 0 else 2,
      includeAll: true,
      label: null,
      name: 'namespace',
      options: [],
      query: 'label_values(process_start_time_seconds, namespace)',
      refresh: 2,
      regex: '',
      type: 'query',
      useTags: false,
    },
}
