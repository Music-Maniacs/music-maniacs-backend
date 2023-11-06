module Versionable
  extend ActiveSupport::Concern

  def author_id_by_versions
    versions.find_by(event: :create).whodunnit
  end

  def history
    versions
  end
end
