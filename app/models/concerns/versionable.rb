module Versionable
  extend ActiveSupport::Concern

  included do
    has_paper_trail versions: { class_name: 'Version' }, ignore: try(:ignored_version_attrs) || []
  end

  def author_id_by_versions
    versions.find_by(event: :create).whodunnit
  end
end
