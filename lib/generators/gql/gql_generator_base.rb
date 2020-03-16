require 'rails/generators/base'
# require 'active_support/extend'
module Gql
  module GqlGeneratorBase
    extend ActiveSupport::Concern

    included do
      protected
      def type_map
        {
          integer: 'Int',
          string: 'String',
          boolean: 'Boolean',
          decimal: 'Float',
          datetime: 'GraphQL::Types::ISO8601DateTime',
          date: 'Types::DateType',
          hstore: 'Types::JSONType',
          text: 'String',
          json: 'Types::JSONType'
        }
      end
  
      def map_model_types(model_name)
        klass = model_name.constantize
        associations = klass.reflect_on_all_associations(:belongs_to)
        bt_columns = associations.map(&:foreign_key)
  
        klass.columns
          .reject { |col| bt_columns.include?(col.name) }
          .reject { |col| type_map[col.type].nil? }
          .map { |col| {name: col.name, gql_type: type_map[col.type]} }
      end
    end
  end
end