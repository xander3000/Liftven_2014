class CreateAccountingServiceOrderPositions < ActiveRecord::Migration
  def self.up
    create_table :accounting_service_order_positions do |t|
      t.references  :accounting_service_order,:null => false
      t.string      :concept,:null => false
      t.float       :quantity,:null => false
      t.date        :delivery_date
      t.float       :sub_total,:null => false
      t.float       :total,:null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_service_order_positions
  end
end
