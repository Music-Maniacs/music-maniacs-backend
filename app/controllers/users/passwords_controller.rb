class Users::PasswordsController < Devise::PasswordsController
  include RackSessionFixController
end
