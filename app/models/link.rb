class Link < ApplicationRecord
  belongs_to :linkeable, polymorphic: true
end
