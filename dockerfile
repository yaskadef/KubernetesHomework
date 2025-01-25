# Используем базовый образ python:3.12-alpine
FROM python:3.12-alpine

# Создаем каталог /app и назначаем его как WORKDIR
WORKDIR /app

# Создаем файл с текстом "Hello World"
RUN echo "Hello World" > index.html

# Добавляем команду для запуска web-сервера
CMD ["python", "-m", "http.server", "8000"]

