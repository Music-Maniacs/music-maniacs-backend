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

* ...

bundle install

rails db:drop

rails db:create

rails db:migrate

rails populate:roles_and_permissions

rails console y luego User.all.each {|u| u.create_user_stat}
