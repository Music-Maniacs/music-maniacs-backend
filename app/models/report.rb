class Report < ApplicationRecord
  enum status: { pending: 0, resolved: 1, rejected: 2 }
  enum category: { inappropriate_content: 0, spam: 1, other: 2 }
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :reporter, class_name: 'User'
  belongs_to :resolver, class_name: 'User'
  belongs_to :reportable, polymorphic: true
end
