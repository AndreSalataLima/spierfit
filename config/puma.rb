# Definir o número de threads mínimo e máximo.
# Esses valores controlam quantas requisições simultâneas um worker pode processar.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }  # Ajuste conforme necessário (padrão: 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Número de workers em produção:
# Reduzimos o número de workers para 1 para diminuir o consumo de memória.
# Para produção no Heroku, definir via ENV ou manter 1 por padrão.
worker_count = Integer(ENV.fetch("WEB_CONCURRENCY") { 1 })  # Inicialmente usar 1 worker
workers worker_count if worker_count > 1  # Garantir que os workers sejam usados apenas se > 1

# Timeout mais longo em desenvolvimento para facilitar o debug.
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Porta que o Puma escutará (Heroku define automaticamente a variável PORT).
port ENV.fetch("PORT") { 3000 }

# Ambiente de execução (development, test, production).
environment ENV.fetch("RAILS_ENV") { "development" }

# Arquivo de PID (process identifier).
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Permitir que o Puma seja reiniciado com `bin/rails restart`.
plugin :tmp_restart

# Configuração SSL (se necessário).
# Apenas ativar SSL no ambiente de desenvolvimento.
if ENV["RAILS_ENV"] == "development"
  ssl_bind '127.0.0.1', '3000', {
    key: 'config/newmyserver.key',
    cert: 'config/newmyserver.crt',
    verify_mode: 'none'
  }
end
