import multiprocessing

bind = 'unix:/tmp/gunicorn.sock'
backlog = 2048

workers = multiprocessing.cpu_count() * 3
worker_class = 'sync'
worker_connections = 1000
timeout = 30
keepalive = 2

# "-" means log to stdout
errorlog = '-'
pidfile = 'gunicorn.pid'
