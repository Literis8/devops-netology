# The URL through which GitLab will be accessed.
external_url "https://gitlab.literis.ru/"

# gitlab.yml configuration
gitlab_rails['time_zone'] = "UTC"
gitlab_rails['backup_keep_time'] = 604800
gitlab_rails['gitlab_email_enabled'] = false

# Default Theme
gitlab_rails['gitlab_default_theme'] = "2"

# Whether to redirect http to https.
nginx['redirect_http_to_https'] = false
nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.literis.ru.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.literis.ru.key"

letsencrypt['enable'] = false

# The directory where Git repositories will be stored.
git_data_dirs({"default" => {"path" => "/var/opt/gitlab/git-data"} })

# The directory where Gitlab backups will be stored
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"

# These settings are documented in more detail at
# https://gitlab.com/gitlab-org/gitlab-ce/blob/master/config/gitlab.yml.example#L118
gitlab_rails['ldap_enabled'] = false

# GitLab Nginx
## See https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/nginx.md
nginx['listen_port'] = "80"
nginx['listen_https'] = false

# Use smtp instead of sendmail/postfix
# More details and example configuration at
# https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/smtp.md
gitlab_rails['smtp_enable'] = false

# 2-way SSL Client Authentication.

# GitLab registry.
registry['enable'] = false


# To change other settings, see:
# https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md#changing-gitlab-yml-settings

node_exporter['enable'] = false