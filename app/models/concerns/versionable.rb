module Versionable
  extend ActiveSupport::Concern

  included do
    has_paper_trail
  end

  def author_id_by_versions
    versions.find_by(event: :create).whodunnit
  end
end
