class CreateAccountingServiceOrders < ActiveRecord::Migration
  def self.up
    create_table :accounting_service_orders do |t|
      t.references  :supplier,:null => false
      t.references  :currency_type,:null => false
      t.references  :create_by,:null => false
      t.date        :posting_date
      t.date        :delivery_date
      t.timestamps
    end
  end

  def self.down
    drop_table :accounting_service_orders
  end
end
