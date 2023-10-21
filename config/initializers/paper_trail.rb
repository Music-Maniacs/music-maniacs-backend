module PaperTrail
  class Version < ActiveRecord::Base
    def self.with_deleted
      all
    end
  end
end
