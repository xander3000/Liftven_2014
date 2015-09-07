class CashBank::DailyCashClosing < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	humanize_attributes		:cash_bank_cash => "Caja",
												:report_z_number => "Reporte Z",
												:date => "Fecha de cierre",
												:total_amount_sales => "Total de ventas",
												:total_amount_cash => "Total en efectivo",
												:total_amount_credit => "Total en TDC",
												:total_amount_debit => "Total en TDD",
												:total_amount_check => "Total en cheques",
												:total_amount_deposit => "Total en depo/trans",
												
												:total_order_amount_with_advance_payment => "Total en ordenes con anticipo",
												:total_order_amount_cash_with_advance_payment => "Total en ordenes con anticipo en efectivo",
												:total_order_amount_credit_with_advance_payment => "Total en ordenes con anticipo en ",
												:total_order_amount_debit_with_advance_payment => "Total en ordenes con anticipo en ",
												:total_order_amount_check_with_advance_payment => "Total en ordenes con anticipo en ",
												:total_order_amount_deposit_with_advance_payment => "Total en ordenes con anticipo en ",
												:total_amount_sales_fiscal => "Total de ventas fiscal",
												:total_amount_cash_fiscal => "Total en efectivo",
												:total_amount_credit_fiscal => "Total en credito",
												:total_amount_debit_fiscal => "Total en debito",
												:total_amount_check_fiscal => "Total en cheque",
												:total_amount_deposit_fiscal => "Total en depo/trans",
												:total_amount_sales_free_form => "Total de ventas por forma libre",
												:total_amount_cash_free_form => "Total en efectivo",
												:total_amount_credit_free_form => "Total en credito",
												:total_amount_debit_free_form => "Total en debito",
												:total_amount_check_free_form => "Total en cheque",
												:total_amount_deposit_free_form => "Total en depo/trans",
												:cash_bank_daily_cash_opening => "Apertura de caja",
												:id => "Cierre de caja diario",
												:base  => "Cierre de caja diario",
												:responsible => "Responsable"

	belongs_to :responsible,:class_name => "User"
	belongs_to :cash_bank_cash,:class_name => "CashBank::Cash"
	belongs_to :cash_bank_daily_cash_opening,:class_name => "CashBank::DailyCashOpening"
	has_one :cash_bank_cash_count_movement,:class_name => "CashBank::CashCountMovement",:foreign_key => :cash_bank_daily_cash_closing_id
	has_one :cash_bank_pos_card_terminal_movement,:class_name => "CashBank::PosCardTerminalMovement",:foreign_key => :cash_bank_daily_cash_closing_id
	validates_presence_of :report_z_number
	validates_presence_of :cash_bank_daily_cash_opening,:message => "no ha sido iniciado"
	validate :fiscal_close_was_complete?
	after_create :close_daily_cash_opening

	#
	# Total en ventas por impresion fiscal
	#
	def total_amount_fiscal
		total_amount_cash_fiscal + total_amount_debit_fiscal + total_amount_credit_fiscal + total_amount_check_fiscal + total_amount_deposit_fiscal
	end

	#
	# Total en ventas por impresion fiscal
	#
	def total_amount_free_form
		total_amount_cash_free_form + total_amount_debit_free_form + total_amount_credit_free_form + total_amount_check_free_form + total_amount_deposit_free_form
	end

	#
	# Total en ventas por impresion fiscal
	#
	def total_amount_with_advance_payment
		total_amount_cash_with_advance_payment + total_amount_debit_with_advance_payment + total_amount_credit_with_advance_payment + total_amount_check_with_advance_payment + total_amount_deposit_with_advance_payment
	end


	#
	# valida si el cierre ficsal fue efectuado
	#
	def fiscal_close_was_complete?
		if not cash_bank_daily_cash_opening.closed_by_fiscal?
			errors.add(:id, "cierre fiscal no se ha llevado a cabo")
			return false
		end
	end

	#
	# Cerra el dia de caja abierto
	#
	def close_daily_cash_opening
		cash_bank_daily_cash_opening.update_attributes(:closed => true,:closed_by_system => true)
	end


end
