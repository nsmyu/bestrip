require 'puma/daemon'

root_dir = '/var/www/bestrip'

max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS', max_threads_count)
threads min_threads_count, max_threads_count

bind "unix://#{root_dir}/tmp/puma.sock"

environment "production"

workers 2
preload_app!

pidfile File.expand_path('tmp/server.pid')

stdout_redirect File.expand_path('log/puma_access.log'), File.expand_path('log/puma_error.log'),
true

plugin :tmp_restart

daemonize
