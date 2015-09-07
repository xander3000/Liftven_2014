class CashBank::Cash < ActiveRecord::Base
	def self.table_name_prefix
    'cash_bank_'
  end

	attr_accessor :accounting_accountant_account_name

	humanize_attributes		:base => "Caja",
												:accounting_accountant_account => "Cuenta contable asociada",
												:accounting_accountant_account_name => "Cuenta contable asociada",
												:name => "Nombre",
												:responsible => "Responsable",
												:has_fiscal_printer => "Tiene impresora fiscal asociada",
												:cash_bank_cash_type => "Tipo de caja"
												


	belongs_to :accounting_accountant_account,:class_name => "Accounting::AccountantAccount",:conditions =>  ["parent_account_id != 0"]
	belongs_to :responsible,:class_name => "User"#,:joins => :user_groups,:conditions => ["user_groups.name IN (?)",UserGroup.all_checker]
	belongs_to :cash_bank_cash_type,:class_name => "CashBank::CashType",:foreign_key => :cash_bank_cash_type_id
	has_many :cash_bank_daily_cash_opening,:class_name => "CashBank::DailyCashOpening",:foreign_key => :cash_bank_cash_id
	has_one :cash_bank_cash_journal_opened,:class_name => "CashBank::CashJournal",:conditions => ["closed = ?",false],:foreign_key => "cash_bank_cash_id"

	validates_presence_of :accounting_accountant_account,
												:responsible,
												:name,
												:cash_bank_cash_type

	#
	# Nombre completo
	#
	def fullname
		"#{id.to_code("05")} - #{name}"
	end


	#
	# Verificia si la caja esta abierta para el dia de hoy
	#
	def without_daily_cash_closing?
		today = Time.now.strftime("%Y-%m-%d")
		daily_cash_opening = cash_bank_daily_cash_opening.first(:conditions => ["date != ? AND closed = ?",today, false])
		if daily_cash_opening
			daily_cash_opening.update_attribute(:closed_by_fiscal, true)
			daily_cash_opening.reload
		end
		daily_cash_opening
	end

	#
	# Verificia si la caja esta abierta para el dia de hoy
	#
	def is_opening_for_today?
		today = Time.now.strftime("%Y-%m-%d")
		cash_bank_daily_cash_opening.first(:conditions => {:date => today,:closed => false}) ? true : false
	end

	#
	# Abre la caja para e dia de hoy
	#
	def opening_for_today
		today = Time.now.strftime("%Y-%m-%d")
		daily_cash_opening = CashBank::DailyCashOpening.new
		daily_cash_opening.cash_bank_cash = self
		daily_cash_opening.date = today
		daily_cash_opening.closed = false
		daily_cash_opening.save
	end

	#
	# Retorna la caja abierta del dia
	#
	def open_for_today(today=Time.now.strftime("%Y-%m-%d"))
		today = Time.now.strftime("%Y-%m-%d") if today.nil?
		daily_cash_opening = cash_bank_daily_cash_opening.first(:conditions => {:date => today})
		daily_cash_opening.reload
		daily_cash_opening
	end

	#
	# Verifica si la caja ya ha sido cerrada por hoy
	#
	def is_closed_for_today?
		today = Time.now.strftime("%Y-%m-%d")
		cash_bank_daily_cash_opening.first(:conditions => ["date = ? AND (closed = ?)",today,true]) ? true : false
	end

	#
	# Verifica si la caja ya ha sido cerrada por hoy
	#
	def is_closed_on_sales_for_today?
		today = Time.now.strftime("%Y-%m-%d")
		cash_bank_daily_cash_opening.first(:conditions => ["date = ? AND (closed = ? OR closed_by_fiscal = ?)",today,true,true]) ? true : false
	end

  #
  # Cajas de tipo caja chica
  #
  def self.all_only_for_journal
    all(:conditions => ["cash_bank_cash_types.tag_name = ?",CashType::CASH_JOURNAL],:joins => :cash_bank_cash_type)
  end

end
