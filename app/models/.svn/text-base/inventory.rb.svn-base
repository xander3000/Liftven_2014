class Inventory < ActiveRecord::Base

  humanize_attributes :quantity => "Cantidad",
                      :date => "Fecha de registro",
                      :reason_inventory => "Razón",
                      :supplier => "Proveedor",
                      :unit_cost => "Costo Unitario",
                      :reference_number => "Número de referencia",
                      :expiration_date => "Fecha de expiración",
                      :remainder => "Remanente"


  belongs_to :category, :polymorphic => true
  belongs_to :reason_inventory
  belongs_to :user
  belongs_to :supplier
  validates_presence_of :reason_inventory,:quantity,:date,:supplier,:unit_cost,:reference_number
  validates_numericality_of :quantity
  
end

