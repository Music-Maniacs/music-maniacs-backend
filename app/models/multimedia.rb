class Multimedia < ApplicationRecord
  self.abstract_class = true
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  has_one_attached :file

  ##############################################################################
  # VALIDATIONS
  ##############################################################################

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def url
    Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
  end

  def full_url
    if Rails.env.development?
      Rails.application.routes.url_helpers.url_for(file)
    else
      file.url
    end
  end
end
