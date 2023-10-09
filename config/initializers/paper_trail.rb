module PaperTrail
  class Version < ActiveRecord::Base
    def user
      User.find_by(id: whodunnit)
    end

    def anonymous?
      user.nil?
    end
    alias anonymous anonymous?

    def named_object_changes
      named_object_changes = object_changes.clone
      named_object_changes.keys.select { |k, _| k.include?('_id') }.each do |key|
        new_values = [resolve_model_name(key, named_object_changes[key][0]), resolve_model_name(key, named_object_changes[key][1])]
        named_object_changes[key.gsub('_id', '')] = new_values
        named_object_changes.delete(key)
      end
      named_object_changes
    end

    # TODO: implementar cache
    def resolve_model_name(key, value)
      klass = key.gsub('_id', '').capitalize.constantize
      klass.find_by(id: value).try(:name)
    end
  end
end
