#!/bin/sh

cd /sync

SECRET=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 50 | head -n1)

echo "\
[server:main]
use = egg:gunicorn
host = 0.0.0.0
port = 5000
workers = 1
timeout = 30
errorlog = -
loglevel = warning
forwarded_allow_ips = *

[app:main]
use = egg:syncserver

[syncserver]
public_url = ${URL}
secret = ${SECRET}
force_wsgi_environ = ${FORCE_WSGI}
[loggers]
keys = root, gunicorn

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = INFO
handlers = console

[logger_gunicorn]
level = WARN
handlers = console
qualname = gunicorn

[handler_console]
class = StreamHandler
args = (sys.stdout,)
formatter = generic

[formatter_generic]
class = mozsvc.util.JsonLogFormatter

" > /sync/syncserver.ini

chown -R "${UID}:${GID}" .

su-exec "${UID}:${GID}" make serve
