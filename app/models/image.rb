class Image < Multimedia
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :imageable, polymorphic: true

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :file, attached: true, content_type: ['image/png', 'image/jpeg', 'image/jpg', 'image/webp']
end
