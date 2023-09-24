module PaperTrail
  class Version < ActiveRecord::Base
    def user
      User.find_by(id: whodunnit)
    end

    def anonymous?
      user.nil?
    end
    alias anonymous anonymous?
  end
end
