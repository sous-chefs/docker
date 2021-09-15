property :log_driver,
         equal_to: %w( json-file syslog journald gelf fluentd awslogs splunk etwlogs gcplogs logentries loki-docker none local ),
         default: 'json-file',
         desired_state: false

property :log_opts,
         [Hash, nil],
         coerce: proc { |v| coerce_log_opts(v) },
         desired_state: false

def coerce_log_opts(v)
  case v
  when Hash, nil
    v
  else
    Array(v).each_with_object({}) do |log_opt, memo|
      key, value = log_opt.split('=', 2)
      memo[key] = value
    end
  end
end

# log_driver and log_opts really handle this
def log_config(value = Chef::NOT_PASSED)
  if value != Chef::NOT_PASSED
    @log_config = value
    log_driver value['Type']
    log_opts value['Config']
  end
  return @log_config if defined?(@log_config)
  def_logcfg = {}
  def_logcfg['Type'] = log_driver if property_is_set?(:log_driver)
  def_logcfg['Config'] = log_opts if property_is_set?(:log_opts)
  def_logcfg = nil if def_logcfg.empty?
  def_logcfg
end
