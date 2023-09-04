class Follower < ApplicationRecord
  belongs_to :followable, polymorphic: true
end
