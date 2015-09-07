class Tracker < ActiveRecord::Base
  belongs_to :tracking_state
  belongs_to :category,:polymorphic => true
	belongs_to :user,:conditions => ["trackers.category_type = ?" ,"User"],:foreign_key => "category_id"


  #
  # Nombre de la categoria
  #
  def name
    category.name
  end


  #
  # Reasignar el tracker actual a un nueva categoria
  #
  def reassign_tracker(user_category)
    update_attributes(:category_id => user_category.id,:category_type => user_category.class.to_s)
  end


end
