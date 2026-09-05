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
    return nil unless file.attached?

    if Rails.env.development?
      if ENV["API_HOST"].present?
        Rails.application.routes.url_helpers.rails_blob_url(file, host: ENV["API_HOST"])
      else
        Rails.application.routes.url_helpers.url_for(file)
      end
    else
      file.url
    end
  end
end
