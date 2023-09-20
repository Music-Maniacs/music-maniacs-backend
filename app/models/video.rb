class Video < Multimedia
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :event
  belongs_to :user

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :file, attached: true, content_type: ['video/mp4']
  validates :recorded_at, presence: true
end
