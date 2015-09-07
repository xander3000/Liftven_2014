class CreatePayrollHistoricalPersonalTypeChanges < ActiveRecord::Migration
  def self.up
    create_table :payroll_historical_personal_type_changes do |t|
      t.references  :payroll_employee,:null => false
      t.references  :user,:null => false
      t.references     :payroll_old_personal_type,:null => false
      t.references     :payroll_new_personal_type,:null => false
      t.string      :date,:default => Time.now.to_date.to_s
      t.text        :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :payroll_historical_personal_type_changes
  end
end
