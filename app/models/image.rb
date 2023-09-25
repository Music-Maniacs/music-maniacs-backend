class Image < Multimedia
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :imageable, polymorphic: true

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :file, attached: true, content_type: ['image/png', 'image/jpeg', 'image/jpg']

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################

  # Marcar como imagen de perfil
  def mark_as_profile
    update(is_profile: true, is_cover: false)
  end

  # Marcar como imagen de portada
  def mark_as_cover
    update(is_profile: false, is_cover: true)
  end

  # Verificar si es una imagen de perfil
  def profile_image?
    is_profile
  end

  # Verificar si es una imagen de portada
  def cover_image?
    is_cover
  end
end
