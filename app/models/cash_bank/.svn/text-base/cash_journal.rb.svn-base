class CashBank::CashJournal < ActiveRecord::Base
  def self.table_name_prefix
    'cash_bank_'
  end

	humanize_attributes		:base => "Caja menor",
                        :cash_bank_cash => "Caja",
                        :cash_bank_cash_id => "Caja",
                        :create_by => "Creado por",
                        :current_balance_amount => "Balance actual",
                        :opening_balance_amount => "Balance de apertura",
                        :total_cash_receipts_amount => "Monto recibido",
                        :total_check_receipts_amount => "Cheques recibidos",
                        :total_cash_payment_amount => "Gastos",
                        :closing_balance_amount => "Balance al cierre",
                        :last_date_rehearing => "Última fecha de reposicion",
                        :closed => "¿Cerrado?",
                        :accounting_concept_create => "Concepto asociado a creación",
												:accounting_concept_rehearing => "Concepto asociado a reposición"

  validates_presence_of :cash_bank_cash,:create_by,:opening_balance_amount,:accounting_concept_rehearing,:accounting_concept_create
  validates_numericality_of :opening_balance_amount,:greater_than => 0,:message => "debe ser mayor a cero"
  validates_numericality_of :opening_balance_amount,:total_cash_receipts_amount,:total_check_receipts_amount,:total_cash_payment_amount
  validates_uniqueness_of :cash_bank_cash_id,:if => Proc.new { |cash_journal| cash_journal and cash_journal.cash_bank_cash.cash_bank_cash_journal_opened },:on => :create

  belongs_to :accounting_concept_create,:class_name => "Accounting::AccountingConcept"
  belongs_to :accounting_concept_rehearing,:class_name => "Accounting::AccountingConcept"
	belongs_to :cash_bank_cash, :class_name => "CashBank::Cash"
  belongs_to :create_by, :class_name => "User"
	has_many :cash_bank_cash_count_positions,:class_name => "CashBank::CashJournalPosition",:foreign_key => "cash_bank_cash_journal_id"

	named_scope :all_opened, lambda { |attr|  { :conditions => ["closed = ?",false]  }}

	

	#
	# Nombre
	#
	def name
		"Caja menor #{cash_bank_cash.name}"
	end

  #
  # Monto total de posicio es no arquedas
  #
  def current_total_amount_positions
    cash_bank_cash_count_positions.all(:conditions => {:count => false}).map(&:total).sum
  end
end
