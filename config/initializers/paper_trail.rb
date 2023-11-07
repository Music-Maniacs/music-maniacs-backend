PaperTrail.config.track_associations = true
module PaperTrail
  class Version < ActiveRecord::Base
    self.abstract_class = true
    self.table_name = :versions
  end
end
