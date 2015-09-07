class CashBank::CashCountPosition < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end
	humanize_attributes		:measure_change_denomination => "Denominación",
												:quantity => "Cantidad",
												:total_amount => "Total"

	belongs_to :measure_change_denomination
	belongs_to :cash_bank_cash_count_movement, :class_name => "CashBank::CashCountMovement"
end
