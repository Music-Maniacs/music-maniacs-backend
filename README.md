# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* Backup
  > Requiere postgres:15 instalado en local (funcionalidad pg_dump)
```
  sudo apt update
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo apt update
  sudo apt install postgresql-15
```
```
  bundle install
  rails db:drop
  rails db:create
  rails db:migrate
  rails populate:roles_and_permissions
  rails console y luego User.all.each {|u| u.create_user_stat}
```


