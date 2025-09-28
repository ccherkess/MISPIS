# Остановка
docker-compose down

# Остановка с удалением volumes
docker-compose down -v

# Перезапуск только Flyway
docker-compose up flyway

# Просмотр статуса миграций
docker-compose run --rm flyway info
