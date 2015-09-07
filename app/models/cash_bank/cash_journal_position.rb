class CashBank::CashJournalPosition < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

  attr_accessor :tenderer_name

	humanize_attributes		:base => "Posición",
                        :id => "Código",
												:cash_bank_cash_journal => "Caja",
                        :cash_bank_cash_journal_position_concept_type => "Concepto",
                        :cash_bank_cash_journal_position_category_type => "Categoría",
                        :total => "Monto",
                        :is_fiscal => "¿Fiscal?",
                        :invoice_sub_total => "SubTotal",
                        :invoice_tax => "IVA",
                        :invoice_tenderer => "Ben/Prov",
                        :invoice_control_number => "N. control",
                        :invoice_reference => "Factura",
                        :invoice_date => "Fecha"

	belongs_to :cash_bank_cash_journal,:class_name => "CashBank::CashJournal"
  belongs_to :cash_bank_cash_journal_position_concept_type,:class_name => "CashBank::CashJournalPositionConceptType"
  belongs_to :cash_bank_cash_journal_position_category_type,:class_name => "CashBank::CashJournalPositionCategoryType"
  belongs_to :invoice_tenderer,:class_name => "Supplier"
	belongs_to :create_by, :class_name => "User"
	belongs_to :currency_type

	validates_presence_of :cash_bank_cash_journal,
												:cash_bank_cash_journal_position_category_type,
												:cash_bank_cash_journal_position_concept_type,
												:total,
												:invoice_tenderer,
												:invoice_date

	validates_presence_of :invoice_sub_total,:invoice_tax,:invoice_reference,:if => Proc.new { |position| position.is_fiscal }
	validate :total_less_than_or_equal_to_current_balance,:on => :create
	after_create :update_current_cash_journal_balance,:create_incoming_invoice



	#
	# Valida si el amount es menor o igual al current_balance_amount de la caja
	#
	def total_less_than_or_equal_to_current_balance
		if new_record? and cash_bank_cash_journal and total > cash_bank_cash_journal.current_balance_amount
				errors.add(:base, "el balance de caja no es suficiente para cubrir el monto")
				return false
		end
	end

	#
	# Sete el balance actual de la caja
	#
	def update_current_cash_journal_balance
		cash_journal_l = cash_bank_cash_journal
		amount = cash_journal_l.current_balance_amount
		payment_amount = cash_journal_l.total_cash_payment_amount
		
		if cash_bank_cash_journal_position_category_type.is_debit
			amount -= total
			payment_amount +=total
		else
			amount += total
		end
		cash_journal_l.update_attributes(:current_balance_amount => amount,:total_cash_payment_amount => payment_amount)

	end

	#
	# Crea cabecera de factura si es fiscal
	#
	def create_incoming_invoice
		if is_fiscal
			incoming_invoice = AccountPayable::IncomingInvoice.new
			incoming_invoice.currency_type = CurrencyType.default
			incoming_invoice.account_payable_incoming_invoice_document_type = AccountPayable::IncomingInvoiceDocumentType.find_by_tag_name(AccountPayable::IncomingInvoiceDocumentType::DIRECT_PAYMENT)
			incoming_invoice.tenderer = invoice_tenderer
			incoming_invoice.supplier = invoice_tenderer
			incoming_invoice.supplier_name = invoice_tenderer.name
			incoming_invoice.create_by = create_by
			incoming_invoice.posting_date = created_at
			incoming_invoice.invoice_date = invoice_date
			incoming_invoice.reference = invoice_reference
			incoming_invoice.control_number = invoice_control_number
			incoming_invoice.description = "Compra caja menor"
			incoming_invoice.sub_total_amount = invoice_sub_total
			incoming_invoice.tax = invoice_tax
			incoming_invoice.total_amount = total
			if incoming_invoice.valid?
				incoming_invoice.save
			end
			incoming_invoice.errors.each do |a,b|
				p "#{a}: #{b}"
			end

		end
	end



end
