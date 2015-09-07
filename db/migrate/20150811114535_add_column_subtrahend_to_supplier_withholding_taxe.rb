class AddColumnSubtrahendToSupplierWithholdingTaxe < ActiveRecord::Migration
  def self.up
    add_column :supplier_withholding_taxes,:subtrahend,:decimal,:scale => 2, :precision => 20,:default => 0
    remove_columns :supplier_withholding_taxes,:max_amount
    Supplier.all.each do |supplier|
      supplier.set_value_is_natural
    end
    SupplierWithholdingTaxe.all.each do |supplier_withholding_taxe|
      if supplier_withholding_taxe.supplier.is_natural
        percentage = supplier_withholding_taxe.accounting_withholding_taxe_type.percentage
        supplier_withholding_taxe.update_attribute(:subtrahend,supplier_withholding_taxe.min_amount*percentage/100)
      end
    end
  end

  def self.down
   remove_columns  :supplier_withholding_taxes,:subtrahend
   add_column :supplier_withholding_taxes,:max_amount,:decimal,:scale => 2, :precision => 20,:default => 0
  end
end