class CashBank::BankMovement < ActiveRecord::Base
	attr_accessor :external_doc_id,
								:external_doc_type,
								:from_external_doc,
								:beneficiary_name

	def self.table_name_prefix
    'cash_bank_'
  end

	humanize_attributes		:cash_bank_bank_movement_operation_type => "Tipo de movimiento",
												:accounting_accounting_concept => "Concepto",
												:cash_bank_bank => "Banco",
												:cash_bank_bank_account => "Cuenta Bancaria",
												:accounting_accountant_account => "Cta. Contable",
												:cash_bank_checkbook => "Chequera",
#												:cash_bank_involvement_type => "Tipo de Afectación",
#												:reference_document=> "Documento referenciado",
#												:reference_document_id => "Documento referenciado",
#												:reference_document_type => "Tipo de Documento referenciado",
												:beneficiary => "Proveedor/Beneficiario",
												:beneficiary_name => "Proveedor/Beneficiario",
												:vale => "Voucher / Comprobante",
												:description => "Descripción",
												:amount => "Monto",
												:debit_amount => "Debito",
												:credit_amount => "Credito",
												:amount_withheld_committed => "Monto sujeto a retención",
												:amount_withheld => "Monto retenido",
												:date => "Fecha",
												:base => "Movimiento en Bancos",
												:id => "Documento",
												:account_balance_to_date => "Balance a la fecha"

	

	has_many :accounting_retention_accounting_types,:class_name => "Accounting::RetentionAccountingType"
	has_many :bank_movement_retention_positions,:class_name => "CashBank::BankMovementRetentionPosition"
	has_many :cash_bank_bank_movement_positions,:class_name => "CashBank::BankMovementPosition",:foreign_key => "cash_bank_bank_movement_id"

	belongs_to :cash_bank_bank_movement_operation_type,:class_name => "CashBank::BankMovementOperationType"#,:conditions => {:visible => true}
	belongs_to :accounting_accounting_concept,:class_name => "Accounting::AccountingConcept"
	belongs_to :cash_bank_bank,:class_name => "CashBank::Bank"
	belongs_to :cash_bank_bank_account,:class_name => "CashBank::BankAccount"
	belongs_to :accounting_accountant_account,:class_name => "Accounting::AccountantAccount"
	belongs_to :cash_bank_checkbook, :class_name => "CashBank::Checkbook"
	belongs_to :create_by,:class_name => "User"
  belongs_to :beneficiary,:class_name => "Supplier"

	validates_presence_of :cash_bank_bank_movement_operation_type,
												:accounting_accounting_concept,
												:cash_bank_bank,
												:cash_bank_bank_account,
												:accounting_accountant_account,
												:vale,
												:amount_withheld_committed,
												:amount_withheld,
												:date

	validates_presence_of :cash_bank_checkbook,:if => Proc.new { |movement| movement.cash_bank_bank_movement_operation_type and movement.cash_bank_bank_movement_operation_type.require_check? }
	validates_numericality_of :amount,:greater_than => 0,:message => "debe ser mayor a cero"
	validates_uniqueness_of :vale,:if =>  Proc.new { |bank_movement| bank_movement.cash_bank_bank_movement_operation_type and not bank_movement.cash_bank_bank_movement_operation_type.is_revert},:on => :create,:scope => [:cash_bank_bank_account_id]
	validates_presence_of :beneficiary
	validates_presence_of :beneficiary_name
	
	validate	:available_check
	#validate	:open_period?,:on => :update
	validate	:amount_less_than_or_equal_to_opening_balance_cash_journal
	

	after_create :set_balance_from_bank_account
	after_create :set_check_offered_by_voucher
	after_create :set_balance_to_cash_journal
	after_create :set_balance_to_create_cash_journal
	after_create :create_transaction_movement_accounting_concept
	#after_validation :set_account_balance_to_date




  #
  # Nombre
  #
  def name
    "Movimiento #{id.to_code}"
  end

  #
  # codigo
  #
  def code
    "CM-"+"%05d" % id
  end

	#
	# Valida si los movimeinto estan completos
	#
	def valid_bank_movement_positions?(bank_movement_positions)
		if bank_movement_positions.empty?
			errors.add(:base, "debe agregar o asociar un compromiso al movimiento")
			return false
		end
		return true
	end

	#
	# Verifica si hay disponiblidad para ejecutar el movimiento en la cuenta seleccionada
	#
	def availability_bank
		if errors.empty?
			current_balance = cash_bank_bank_account.current_balance
			if amount.to_f > current_balance and  cash_bank_bank_movement_operation_type.is_debit?
				errors.add(:cash_bank_bank_account, "no tiene disponibilidad para cubrir este movimiento")
				return false
			end
		end
	end

	#
	# Balance a la fecha con movimiento
	#
	def account_balance_to_date_with_movement
		if cash_bank_bank_movement_operation_type.is_debit
			account_balance_to_date - amount
		else
			account_balance_to_date + amount
		end
	end

	#
	# Nombre del beneficiario
	#
	def beneficiary_name
		beneficiary.name if beneficiary
	end

	#
	# Valida si el monto no excede el balance de apertura de la caja si esta asociado a un concepto
	#
	def amount_less_than_or_equal_to_opening_balance_cash_journal
		if accounting_accounting_concept
			cash_journal = accounting_accounting_concept.cash_bank_cash_journal_to_rehearing
			if cash_journal
				current_amount = cash_journal.current_balance_amount
				opening_amount = cash_journal.opening_balance_amount
				if amount > (opening_amount - current_amount)
					errors.add(:amount,"excede monto o balance actual del concepto referenciado a la #{cash_journal.name}")
					return false
				end
			end
		end
	end



	#
	# Modifica el balance del acuenta afectada
	#
	def set_balance_from_bank_account
		current_balance = cash_bank_bank_account.current_balance
		if cash_bank_bank_movement_operation_type.is_debit
			current_balance -= amount
		else
			current_balance += amount
		end
		cash_bank_bank_account.update_attribute(:current_balance, current_balance)
	end



	#
	# Modifica el balance del acuenta afectada
	#
	def set_account_balance_to_date
		if errors.empty?
			current_balance = cash_bank_bank_account.current_balance
			update_attributes!(:account_balance_to_date => current_balance)
		end
	end

	#
	# Cambia el sttaus de docuemnto refenciado si aplica
	#
	def set_status_document_reference
		if require_reference_document?
			reference_document.status_to_paid
		end
	end

	#
	# Set el balance de una caja menor si aplica
	#
	def set_balance_to_cash_journal
		cash_journal = accounting_accounting_concept.cash_bank_cash_journal_to_rehearing
		if cash_journal
			current_amount = cash_journal.current_balance_amount
			cash_journal.update_attributes(:current_balance_amount => (current_amount + amount),:last_date_rehearing => Time.now.to_date.to_s)
		end
	end

	#
	# Set el balance de una caja menor si aplica para crearla
	#
	def set_balance_to_create_cash_journal
		cash_journal = accounting_accounting_concept.cash_bank_cash_journal_to_create
		if cash_journal
			current_amount = cash_journal.current_balance_amount
			cash_journal.update_attributes(:current_balance_amount => (current_amount + amount),:last_date_rehearing => Time.now.to_date.to_s)
		end
	end  

  #
  # Registra transqaccion contable
  #
  def create_transaction_movement_accounting_concept
    transaction_movement_accounting_concept_bank = Accounting::TransactionMovementAccountingConcept.new
		transaction_movement_accounting_concept_bank.accounting_accountant_account = cash_bank_bank_account.accounting_accountant_account
		transaction_movement_accounting_concept_bank.create_by = create_by
		transaction_movement_accounting_concept_bank.reference_document = self
		if cash_bank_bank_movement_operation_type.is_debit
			transaction_movement_accounting_concept_bank.credit = amount
		else
			transaction_movement_accounting_concept_bank.debit = amount
		end
		transaction_movement_accounting_concept_bank.date = date
		if transaction_movement_accounting_concept_bank.valid?
			transaction_movement_accounting_concept_bank.save
		end

		transaction_movement_accounting_concept_concept = Accounting::TransactionMovementAccountingConcept.new
		transaction_movement_accounting_concept_concept.accounting_accountant_account = accounting_accounting_concept.accounting_accountant_account
		transaction_movement_accounting_concept_concept.create_by = create_by
		transaction_movement_accounting_concept_concept.reference_document = self
		if cash_bank_bank_movement_operation_type.is_debit
			transaction_movement_accounting_concept_concept.debit = amount
		else
			transaction_movement_accounting_concept_concept.credit = amount
		end
		transaction_movement_accounting_concept_concept.date = date
		if transaction_movement_accounting_concept_concept.valid?
			transaction_movement_accounting_concept_concept.save
		end
  end
  
  
	#
	# Requiere docuemnto referncial
	#
	def require_reference_document?
		cash_bank_involvement_type.require_reference_document and reference_document
	end

	#
	# Agrgar o registra cheuqe si aplica
	#
	def set_check_offered_by_voucher
		if cash_bank_bank_movement_operation_type.require_check?
			cash_bank_checkbook.register_issued_check_offered(1,amount,vale,date,beneficiary,self)
		end
	end

	#
	# Verifica si el vale asociado a un cheuqe esta disponible
	#
	def available_check
		if  errors.empty? and cash_bank_bank_movement_operation_type.require_check?
			if cash_bank_checkbook.cash_bank_check_offereds.map(&:number).include?(vale.to_i)
				errors.add(:vale, "número de cheque usado")
				return false
			end
		end
	end


	#
	# Reversa el movimiento
	#
	def revert
		#TODO: colocar docuemnto reversado
		revert_movement = self.class.new(attributes)
		revert_movement.id = nil
		revert_movement.description = "Reverso por carga invalida"
		revert_movement.reference_document_id = self.id
		revert_movement.reference_document_type = self.class.to_s
		revert_movement.beneficiary = "INDEFINIDO" if beneficiary.eql?("")
		if cash_bank_bank_movement_operation_type.is_debit?
				revert_movement.cash_bank_bank_movement_operation_type = CashBank::BankMovementOperationType.find_by_tag_name(CashBank::BankMovementOperationType::CREDITO_REVERSO)
		else
				revert_movement.cash_bank_bank_movement_operation_type = CashBank::BankMovementOperationType.find_by_tag_name(CashBank::BankMovementOperationType::DEBITO_REVERSO)
		end
		success = revert_movement.valid?
		if success
			revert_movement.save
		end
		{:success => success,:object => revert_movement}
	end

	#
	# debit  amount
	#
	def debit_amount
		if cash_bank_bank_movement_operation_type.is_debit?
			amount
		else
			0.0
		end
	end

	#
	# credit  amount
	#
	def credit_amount
		if not cash_bank_bank_movement_operation_type.is_debit?
			amount
		else
			0.0
		end
	end


	#
	# Link de show
	#
	def link_show(content)
    "<a href='#{ActionController::Base.relative_url_root}/backend/cashbank/bank_movements/#{id}'>#{content}</a>"
  end

	#
	#
	#
	def open_period?
		period = date[3,date.length]
		#TODO BUcar en los periodos abiertos
	end

	#
	# Tipo de docuemnto tipo Debito
	#
	def self.document_reference_debit_types
		{AccountPayable::IncomingInvoice.model_humanize_name => AccountPayable::IncomingInvoice.to_s}
	end

	#
	# Tipo de docuemnto tipo Credito
	#
	def self.document_reference_credit_types
		{Invoice.model_humanize_name => Invoice.to_s,Accounting::Advance.model_humanize_name => Accounting::Advance.to_s}
	end

	#
	# all_by_options
	#
	def self.all_by_options(options={})
		options[:length] = options[:length] || 10
    options[:start] = options[:start] || 0
		options[:page] = options[:start].to_i / options[:length].to_i + 1
    options[:draw] = options[:draw].to_i  || 1
		options[:query] = options[:search][:value] || ""



		clausules = []
		values = []
		conditions  = []
		if !options[:query].empty?
			clausules << "amount LIKE ?"
			values << "%#{options[:query]}%"
		end
		conditions << clausules.join(" AND ")
		conditions.concat( values )


		data = []
		bank_movements = all(:conditions => conditions,:order => "id desc")
		bank_movements_paginate = bank_movements.paginate(:page => options[:page], :per_page => options[:length],:conditions => conditions)
		bank_movements_paginate.each do |bank_movement|
				data << [
									bank_movement.link_show(bank_movement.id.to_code),
									bank_movement.cash_bank_bank_movement_operation_type.name,
									bank_movement.accounting_accounting_concept.name,
									bank_movement.cash_bank_bank.name,
									bank_movement.cash_bank_bank_account.number,
									bank_movement.vale,
									bank_movement.amount.to_currency(false),
									I18n.l(bank_movement.date.to_date),
									bank_movement.account_balance_to_date.to_currency(false)
								]
		end
		

		rows = {
          "draw" => options[:draw],
          "recordsTotal" => bank_movements.size,
          "recordsFiltered" => bank_movements.size,
					"data" => data
					
          }
		JSON.generate(rows)
	end

	#
	#
	#
	def self.document_reference_is_debit_type(referent_document)
		is_debit_type = false
		document_reference_debit_types.each do |key,value|
				is_debit_type ||= value.eql?(referent_document.class.to_s)
		end
		is_debit_type
	end

	#
	# Busqueda por criterio
	#
	def self.all_by_criterion(options={})

			clausules = []
      values = []
      conditions  = []
			banks = []
			results = []


		if !options[:accounting_concept].eql?("")
			clausules << "accounting_accounting_concept_id = ?"
			values << options[:accounting_concept]
		end

		if !options[:bank].eql?("")
			banks = [CashBank::Bank.find(options[:bank])]
		else
			banks = CashBank::Bank.all
		end

		if !options[:bank_account].eql?("")
			clausules << "cash_bank_bank_account_id = ?"
			values << options[:bank_account]
		end


		if !options[:bank_movement_operation_type].eql?("")
			clausules << "cash_bank_bank_movement_operation_type_id = ?"
			values << options[:bank_movement_operation_type]
		end

		if !options[:beneficiary].eql?("")
			clausules << "beneficiary_id = ?"
			values << options[:beneficiary]
		end

		if !options[:date_from].eql?("")
			clausules << "date >= ?"
			values << options[:date_from]
		end

		if !options[:date_to].eql?("")
			clausules << "date <= ?"
			values << options[:date_to]
		end
		
		clausules_aux = clausules.clone
		values_aux = values.clone
		banks.each do |bank|
			conditions  = []
			clausules = clausules_aux.clone
			values = values_aux.clone
			clausules << "cash_bank_bank_id = ?"
			values << bank.id
			conditions << clausules.join(" AND ")
			conditions.concat( values )

			results << [bank, all(:conditions => conditions,:order => "date asc")]
		end

		results
	end


	#
	# Contigencia
	#
	def self.restructuring_balances

		CashBank::BankAccount.all.each do |bank_account|
			current_balance = bank_account.initial_balance
			bank_account.cash_bank_bank_movements.each do |cash_bank_bank_movement|
				
				if cash_bank_bank_movement.cash_bank_bank_movement_operation_type.is_debit
					current_balance -= cash_bank_bank_movement.amount
				else
					current_balance += cash_bank_bank_movement.amount
				end
				cash_bank_bank_movement.update_attribute(:account_balance_to_date, current_balance)
				cash_bank_bank_movement.cash_bank_bank_account.update_attribute(:current_balance, current_balance)
			end

		end
	end

end

