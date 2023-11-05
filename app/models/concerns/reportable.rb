module Reportable
  extend ActiveSupport::Concern

  included do
    has_many :reports, as: :reportable
    before_destroy :destroy_pending_reports

    # si se elimina un reportable, al pedo que sigan estando los reports
    def destroy_pending_reports
      reports.pending.destroy_all
    end
  end

  def author_id
    raise 'show be implemented in the model'
  end
end
