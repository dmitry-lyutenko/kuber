# Kubernetes Vagrant Ansible

## Vagrantfile

Разворачивает локальную сеть `10.12.12.0/24` из 3 нод и мастера. Для доступа к сети есть маршрутник `gw`, через него же и доступ машин к внешему миру. На всех создаваемых виртуалках есть пользователь `core`, с авторизацией по ключу и `sudo` без пароля.

## Ansible

Разворачивает Kubernetes на 3 ноды с одним мастером.

## Additional

### docker-mysql-node
Исходник для развертывания mysql-ноды

### docker-mysql-router
Исходник для развертывания mysql-роутера

### yml
yml-файлы для кластера. Ссылается на репозиторий с образами докера `k8s-docker.k8s.local` Локальный репозиторий.

### docker-registry
Сам локальный репозиторий (docker-compose.yml)

### coredns
DNS-сервер (docker-compose.yml) обслуживал домен `.k8s.local`



## ToDo

Дотюнить сеть, ибо пока работает только NodePort. LoadBalancer не реализован.
