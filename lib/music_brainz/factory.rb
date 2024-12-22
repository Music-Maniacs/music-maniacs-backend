# frozen_string_literal: true

module MusicBrainz
  # Factory se encarga de crear clases anónimas dinámicamente en función del nombre de una tabla, y las setea como constantes de Model
  class Factory
    def self.initialize
      tables = Model::BaseModel.connection.tables
      tables.each do |table_name|
        model(table_name)
      end

      # tables.each do |table_name|
      #   klass = Model.const_get(classify_table_name(table_name))

      #   begin
      #     klass.column_names.each do |column_name|
      #       if Model.const_defined?(classify_table_name(column_name))
      #         puts "#{classify_table_name(table_name)} belongs_to #{classify_table_name(column_name)}}"
      #         # klass.belongs_to column_name.to_sym, class_name: classify_table_name(column_name)
      #       end
      #     end
      #   rescue StandardError => e
      #     byebug
      #   end
      # end
    end

    def self.define(&block)
      factory = new
      factory.instance_eval(&block)
      factory
    end

    def self.model(table_name, &block)
      klass = model_class(table_name)
      klass.class_eval(&block) if block_given?
      klass
    end

    def self.classify_table_name(table_name)
      table_name.classify
    end

    def self.model_class(table_name)
      Model.const_get(classify_table_name(table_name))
    rescue NameError
      build_model_class(table_name)
    end

    def self.build_model_class(table_name)
      klass = Class.new Model::BaseModel do
        self.table_name = table_name
        # self.inheritance_column = :_sti_type
      end
      Model.const_set(classify_table_name(table_name), klass)
    end
  end
end
