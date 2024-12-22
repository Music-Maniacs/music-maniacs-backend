# frozen_string_literal: true

module MusicBrainz
  module Model
    # used as a parent class for all models
    class BaseModel < ActiveRecord::Base
      self.abstract_class = true

      connects_to database: { writing: :music_brainz, reading: :music_brainz }
    end
  end
end
