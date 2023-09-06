module Followable
  extend ActiveSupport::Concern

  included do
    has_many :follows, dependent: :destroy, as: :followable
    has_many :followers, through: :follows, source: :user
  end
end
