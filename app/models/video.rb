class Video < Multimedia
  include Likeable
  include Reportable
  acts_as_paranoid
  ##############################################################################
  # ASSOCIATIONS
  ##############################################################################
  belongs_to :event
  belongs_to :user

  ##############################################################################
  # VALIDATIONS
  ##############################################################################
  validates :file, attached: true, content_type: ['video/mp4']
  validates :recorded_at, :name, presence: true

  ##############################################################################
  # INSTANCE METHODS
  ##############################################################################
  def anonymous?
    user.nil?
  end
  alias anonymous anonymous?

  def author_id
    user_id
  end
end
