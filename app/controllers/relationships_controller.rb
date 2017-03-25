class RelationshipsController < ApplicationController

  load_and_authorize_resource


  respond_to :json

  def new
    @relationship = Relationship.new
  end

  def create
    @relationship = Relationship.create(relationship_params)
  end

  def destroy
    @relationship.destroy
  end

  def update
    @relationship.update_attributes(relationship_params)
    respond_with @relationship
  end

  private

  def relationship_params
    params.require(:relationship)
  end
end
