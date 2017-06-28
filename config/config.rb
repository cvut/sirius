require "pliny/config_helpers"

# Access all config keys like the following:
#
#     Config.database_url
#
# Each accessor corresponds directly to an ENV key, which has the same name
# except upcased, i.e. `DATABASE_URL`.
module Config
  extend Pliny::CastingConfigHelpers

  # Mandatory -- exception is raised for these variables when missing.
  mandatory :database_url,                string
  mandatory :domain,                      string
  mandatory :elastic_url,                 string
  mandatory :oauth_client_id,             string
  mandatory :oauth_client_secret,         string

  # Optional -- value is returned or `nil` if it wasn't present.
  optional :console_banner,               string
  optional :placeholder,                  string
  optional :sentry_dsn,                   string
  optional :sync_schedule,                string
  optional :versioning_app_name,          string
  optional :versioning_default,           string

  # Override -- value is returned or the set default.
  override :database_timeout,       10,               int
  override :db_pool_max_size,       3,                int
  override :deployment,             'production',     string
  override :elastic_prefix,         'sirius',         string
  override :force_ssl,              true,             bool
  override :oauth_check_token_uri,  'https://auth.fit.cvut.cz/oauth/oauth/check_token', string
  override :oauth_auth_uri,         'https://auth.fit.cvut.cz/oauth/authorize', string
  override :oauth_token_uri,        'https://auth.fit.cvut.cz/oauth/token', string
  override :umapi_people_uri,       'https://kosapi.fit.cvut.cz/usermap/v1/people', string
  override :umapi_privileged_roles, 'B-00000-ZAMESTNANEC', array(string)

  override :port,                   5000,             int
  override :pretty_json,            false,            bool
  override :rack_env,               'development',    string
  override :raise_errors,           false,            bool
  override :root,                   File.expand_path('../', __dir__), string
  override :timeout,                10,               int
  override :tz,                     'Europe/Prague',  string
  override :versioning,             false,            bool

  override :puma_max_threads,       16,               int
  override :puma_min_threads,       1,                int
  override :puma_workers,           3,                int
end
