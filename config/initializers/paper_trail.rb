module PaperTrail
  class Version < ActiveRecord::Base
    self.abstract_class = true
  end
end
