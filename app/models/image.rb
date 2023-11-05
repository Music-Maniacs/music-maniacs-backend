class Image < Multimedia
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :imageable, polymorphic: true

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :file, attached: true, content_type: ['image/png', 'image/jpeg', 'image/jpg', 'image/webp']

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def convert_to_webp
    return unless file.attached?

    # Verifica si el archivo adjunto es una imagen
    if file.content_type.start_with?('image')
      # Convierte la imagen a formato WebP
      img = MiniMagick::Image.read(file.download)
      img.format('webp')

      # Guarda la imagen en formato WebP
      file.purge # Elimina la imagen original
      file.attach(io: StringIO.new(img.to_blob), filename: 'image.webp', content_type: 'image/webp')
    end
  end
end
