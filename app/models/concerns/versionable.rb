module Versionable
  extend ActiveSupport::Concern

  included do
    has_paper_trail class_name: 'Version'
  end

  def author_id_by_versions
    versions.find_by(event: :create).whodunnit
  end
end
