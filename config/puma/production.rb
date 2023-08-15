environment "production"

root_dir = '/var/www/bestrip'
bind "unix://#{root_dir}/sockets/puma.sock"

threads 3, 3
workers 2
preload_app!

pidfile "#{tmp_path}/pids/puma.pid"

plugin :tmp_restart
