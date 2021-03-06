# graphql-rails-generators

A few generators to make it easy to integrate your Rails models with [graphql-ruby](https://github.com/rmosolgo/graphql-ruby). I created this because I was wasting too many keystrokes copying my model schema by hand to create graphql types.

This project contains three generators that look at your ActiveRecord model schema and generates graphql types for you.

* `gql:model_type Post` - Generate a graphql type for a model
* `gql:input Post` - Generate a graphql input type for a model
* `gql:mutation Update Post` - Generate a graphql mutation class for a model

## Installation

```
gem 'graphql-rails-generators', group: :development
```

## Requirements

This library only supports ActiveRecord, though it would be fairly trivial to add support for other ORMs.

## Usage

### gql:model_type

Generate a model type from a model.

```
$ rails generate gql:model_type MODEL_CLASS
```

Result:

```ruby
# app/graphql/post_type.rb
module Types
  class PostType < Types::BaseObject
    field :id, Int, null: true
    field :title, String, null: true
    field :body, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end
```

### gql:input MODEL_CLASS

Generate an input type from a model.

```
rails generate gql:input Post
```

Result:
```ruby
# app/graphql/types/post_input.rb
module Types
  module Input
    class PostInput < Types::BaseInputObject
      argument :title, String, required: false
      argument :body, String, required: false
    end
  end
end
```

### gql:mutation MUTATION_PREFIX MODEL_NAME

Generate a mutation class from a model.

A quick note about the mutation generator...

The mutation generator generates something akin to an "upsert" mutation. It takes two arguments: an optional `id` and an optional `attributes`, which is the input type for the model. If you pass an `id`, it will attempt to find the model by the `id` and update it, otherwise it will initialize a new model and attempt to save it.

```
rails generate gql:mutation Update Post
```

Result:
```ruby
# app/graphql/mutations/update_post.rb
module Mutations
  class UpdatePost < Mutations::BaseMutation
    field :post, Types::PostType, null: true

    argument :attributes, Types::Input::PostInput, required: true
    argument :id, Int, required: false

    def resolve(attributes:, id: nil)
      model = find_or_build_model(id)
      model.attributes = attributes.to_h
      if model.save
        {post: model}
      else
        {errors: model.errors.full_messages}
      end
    end

    def find_or_build_model(id)
      if id
        Post.find(id)
      else
        Post.new
      end
    end
  end
end
```