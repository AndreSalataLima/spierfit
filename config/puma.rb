threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads threads_count, threads_count

worker_count = ENV.fetch("WEB_CONCURRENCY", 1).to_i
workers worker_count if worker_count > 1

worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

port ENV.fetch("PORT", 3000)

environment ENV.fetch("RAILS_ENV", "development")

pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

plugin :tmp_restart
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# SSL para desenvolvimento (se estiver usando certificados locais)
if ENV["RAILS_ENV"] == "development"
  ssl_bind '127.0.0.1', '3000', {
    key: 'config/newmyserver.key',
    cert: 'config/newmyserver.crt',
    verify_mode: 'none'
  }
end
