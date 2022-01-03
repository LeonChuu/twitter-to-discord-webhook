import Config

debug_level = String.to_atom(System.get_env("DEBUG_LEVEL","info"))
config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: debug_level]
  ]
