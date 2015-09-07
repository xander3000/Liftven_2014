class IncomingInvoiceBilling < ActiveRecord::Base
	attr_accessor :bank_movements
	
   humanize_attributes  :payment_method_type => "Forma de pago",
                        :transaction_reference => "Referencia de transacción",
                        :transaction_date => "Fecha de transacción",
												:amount => "Monto",
												:created_at => "Fecha contable",
												:cash_bank_pos_card_terminal => "Punto de Venta",
												:bank_movements => "Movimiento bancario"
											
	belongs_to :invoice
	belongs_to :payment_method_type
	belongs_to :cash_bank_pos_card_terminal,:class_name => "CashBank::PosCardTerminal"

	validates_presence_of :payment_method_type,
												:amount

	validates_presence_of :transaction_reference,:transaction_date,:if => Proc.new { |item| item.payment_method_type and item.payment_method_type.require_additional_information }
	validates_presence_of :cash_bank_pos_card_terminal,:if => Proc.new { |item| item.payment_method_type and item.payment_method_type.is_credit_debit_card? }
	#validate	:reached_maximum_amount,:if => Proc.new { |item| not item.invoice.nil? }
	before_validation :set_transaction_date_defalult_value

	after_create :update_invoice_balance,:create_bank_movement

	validate :validate_bank_movement
	




	#
	# Setear fecha actual en caso de que transaction_date sea blanco
	#
	def set_transaction_date_defalult_value
		self.transaction_date = Time.now.strftime("%Y-%m-%d") if self.transaction_date.nil? or self.transaction_date.blank?
	end

	#
	# Actualizar balnce nuevo pago
	#
	def update_invoice_balance
		invoice.reload
		invoice.update_attribute(:balance, invoice.current_balance)
	end




	#
	#
	#
	def validate_bank_movement
		if errors.empty? and payment_method_type.is_credit_debit_card?
			bank_movement = asociate_bank_movement(CashBank::BankMovementOperationType.by_pos_debit_credit)
			if !bank_movement.valid?
				bank_movement_errors = []
				bank_movement.errors.each do |a,b|
					bank_movement_errors << "-#{CashBank::BankMovement.human_attribute_name(a)} #{b}"
				end
				errors.add(:bank_movements,bank_movement_errors.join(", "))
				return false
			end
		end
	end

	#
	# Asocia un moviemeinto bancario al pago
	#
	def asociate_bank_movement(operation_type,validate=true)

			bank_movement = CashBank::BankMovement.new
			bank_movement.create_by = User.find_by_login("admin")
			bank_movement.cash_bank_bank_movement_operation_type = operation_type
			bank_movement.accounting_accounting_concept = Accounting::AccountingConcept.first(:conditions => ["accounting_accounting_concept_operation_types.tag_name = ? AND lower(accounting_accounting_concepts.name) = ?","mbi","ventas"],:joins => [:accounting_accounting_concept_operation_type])
			cash_bank_bank_account_aux =  cash_bank_pos_card_terminal.cash_bank_bank_account
			bank_movement.cash_bank_bank = cash_bank_bank_account_aux.cash_bank_bank
			bank_movement.cash_bank_bank_account = cash_bank_bank_account_aux
			bank_movement.accounting_accountant_account = cash_bank_bank_account_aux.accounting_accountant_account
			bank_movement.account_balance_to_date = cash_bank_bank_account_aux.current_balance
			bank_movement.cash_bank_involvement_type = CashBank::InvolvementType.accrued_collected
			bank_movement.description = (invoice_id ? "Pago factura #{invoice_id} con #{payment_method_type.name}" : "N/A")
			bank_movement.vale = transaction_reference
			bank_movement.date =  transaction_date
			bank_movement.amount = amount
			bank_movement.beneficiary = Supplier.find_owner
			bank_movement.valid? if validate
		bank_movement
	end

	#
	# Crea un moviemineto bancario si se trata de una transacion de TDC o TDD
	#
	def create_bank_movement
		if payment_method_type.is_credit_debit_card?
			bank_movement = asociate_bank_movement(CashBank::BankMovementOperationType.by_pos_debit_credit)
			if bank_movement.valid?
				bank_movement.save
				bank_movement_position = CashBank::BankMovementPosition.new
				bank_movement_position.bank_movement = bank_movement
				bank_movement_position.reference = transaction_reference
				bank_movement_position.description = bank_movement.description
				bank_movement_position.amount = amount
				bank_movement_position.save
			else
				bank_movement.errors.each do |a,b|
					logger.info "********* create_bank_movement *************"
					logger.info "ERROR IN create_bank_movement:#{a}: #{b}"
					logger.info "********************************************"
				end
			end
		end
		
	end

	#
	# Valida si el amonto actual mas los pagos antyeriores no alncanzal en monto de la factura
	#
	def reached_maximum_amount
		if (invoice.amount_payments + self.amount.to_f).round(2) > invoice.total.round(2)
			errors.add(:amount,"execede el total de la factura")
		end
	end

	#
	# Decuelte el total em monto de las tranacciones del dia por impresion fiscal
	#
	def self.total_amount_today_fiscal_transactions(today=Time.now.strftime("%Y-%m-%d"),options={})
		today=Time.now.strftime("%Y-%m-%d") if today.nil?
		totals = {}
		all = 0
		invoice_printing_type = InvoicePrintingType.find_by_tag_name(InvoicePrintingType::FISCAL)
		cash = PaymentMethodType.find_by_tag_name(PaymentMethodType::EFECTIVO)
		PaymentMethodType.find_all_by_daily_cash_closing.each do |payment|
		conditions = ["incoming_invoice_billings.created_at >= ? AND incoming_invoice_billings.created_at <= ? AND incoming_invoice_billings.payment_method_type_id = ? AND invoices.printed = ? AND invoices.invoice_printing_type_id = ? AND (incoming_invoice_billings.is_advance_payment = ? OR (incoming_invoice_billings.is_advance_payment = ? AND (incoming_invoice_billings.transaction_date = ? OR incoming_invoice_billings.payment_method_type_id = ?)))","#{today} 00:00:00","#{today} 23:59:59", payment.id,true,invoice_printing_type.id,false,true,today,cash.id]
		#conditions = ["incoming_invoice_billings.created_at >= ? AND incoming_invoice_billings.created_at <= ? AND incoming_invoice_billings.payment_method_type_id = ? AND invoices.printed = ? AND invoices.invoice_printing_type_id = ? AND (incoming_invoice_billings.is_advance_payment = ? OR (incoming_invoice_billings.is_advance_payment = ? AND (incoming_invoice_billings.transaction_date = ?)))","#{today} 00:00:00","#{today} 23:59:59", payment.id,true,invoice_printing_type.id,false,true,today]

			if options.has_key?(:only_records)
			 totals[payment.tag_name] = all(:conditions => conditions,:joins => [:invoice])
		 else
			 totals[payment.tag_name] = sum(:amount,:conditions => conditions,:joins => [:invoice]).to_f.round(2)
				all +=  totals[payment.tag_name]
		 end
			
		end
		totals["all"] = all
		totals["today"] = today
		totals
	end

	#
	# Decuelte el total em monto de las tranacciones del dia
	#
	def self.total_amount_today_fiscal_free_form(today=Time.now.strftime("%Y-%m-%d"),options={})
		today=Time.now.strftime("%Y-%m-%d") if today.nil?
		totals = {}
		all = 0
		invoice_printing_type = InvoicePrintingType.find_by_tag_name(InvoicePrintingType::LIBRE)
		cash = PaymentMethodType.find_by_tag_name(PaymentMethodType::EFECTIVO)
		PaymentMethodType.find_all_by_daily_cash_closing.each do |payment|
			conditions = ["incoming_invoice_billings.created_at >=  ?  AND  incoming_invoice_billings.created_at <= ? AND incoming_invoice_billings.payment_method_type_id = ? AND invoices.printed = ? AND invoices.invoice_printing_type_id = ? AND (incoming_invoice_billings.is_advance_payment = ? OR (incoming_invoice_billings.is_advance_payment = ? AND (incoming_invoice_billings.transaction_date = ? OR incoming_invoice_billings.payment_method_type_id = ?)))","#{today} 00:00:00","#{today} 23:59:59", payment.id,true,invoice_printing_type.id,false,true,today,cash.id]
			#conditions = ["incoming_invoice_billings.created_at >=  ?  AND  incoming_invoice_billings.created_at <= ? AND incoming_invoice_billings.payment_method_type_id = ? AND invoices.printed = ? AND invoices.invoice_printing_type_id = ? AND (incoming_invoice_billings.is_advance_payment = ? OR (incoming_invoice_billings.is_advance_payment = ? AND (incoming_invoice_billings.transaction_date = ?)))","#{today} 00:00:00","#{today} 23:59:59", payment.id,true,invoice_printing_type.id,false,true,today]

			 if options.has_key?(:only_records)
				totals[payment.tag_name] = all(:conditions => conditions,:joins => [:invoice])
			 else
				totals[payment.tag_name] = sum(:amount,:conditions => conditions,:joins => [:invoice]).to_f.round(2)
				all +=  totals[payment.tag_name]
			 end
		end
		totals["all"] = all
		totals["today"] = today
		totals
	end


end
