#!/bin/sh
# wait-for-oracle.sh

host="$1"
port="$2"
shift 2
cmd="$@"

echo "Esperando a Oracle en $host:$port..."

while ! nc -z "$host" "$port"; do
  sleep 2
done

echo "Oracle listo! Ejecutando: $cmd"
exec $cmd