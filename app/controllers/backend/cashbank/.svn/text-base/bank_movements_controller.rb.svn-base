class Backend::Cashbank::BankMovementsController < Backend::Cashbank::BaseController
	helper_method :current_bank_movement_positions_objects

	def index
		@title = "Movimiento en Bancos / Libro de Banco"
		
		respond_to do |format|

				format.html
				format.json do
					@bank_movements = CashBank::BankMovement.all_by_options(params)
					 render :json => @bank_movements
				end
		end
	end

	def new
		current_bank_movement_positions_clear
		@title = "Movimiento en Bancos / Nuevo movimiento"
		@bank_movement = CashBank::BankMovement.new
		@retention_accounting_types = Accounting::RetentionAccountingType.all
		@bank_movement_operation_types = CashBank::BankMovementOperationType.all_visibles
	end

  def new_bank_movement_from_receivable_account
    current_bank_movement_positions_clear
    @title = "Movimiento en Bancos / Nuevo movimiento"
		@bank_movement = CashBank::BankMovement.new
		receivable_account = Accounting::ReceivableAccount.find_by_id(params[:receivable_account_id])
		@bank_movement.beneficiary = Supplier.find_owner
		@bank_movement.reference_document_id = receivable_account.doc.id
		@bank_movement.external_doc_id = receivable_account.doc.id
		@bank_movement.external_doc_type = receivable_account.doc.class.to_s

		@retention_accounting_types = Accounting::RetentionAccountingType.all
		@bank_movement_operation_types = CashBank::BankMovementOperationType.all_visibles_credit
    render :action =>"new"
  end

	def create
		@bank_movement = CashBank::BankMovement.new(params[:cash_bank_bank_movement])
		@bank_movement.create_by = current_user
		cash_bank_retention_accounting_types = params[:cash_bank_retention_accounting_type] ? params[:cash_bank_retention_accounting_type] : []
		@success = @bank_movement.valid?
		@success &= @bank_movement.valid_bank_movement_positions?(current_bank_movement_positions_objects)
		
		if @success
			@bank_movement.set_account_balance_to_date
			@bank_movement.save
			current_bank_movement_positions_objects.each do |bank_movement_position|
				bank_movement_position.bank_movement = @bank_movement
				bank_movement_position.save
			end
			cash_bank_retention_accounting_types.each do |cash_bank_retention_accounting_type|
				bank_movement_retention_position = CashBank::BankMovementRetentionPosition.new
				bank_movement_retention_position.bank_movement = @bank_movement
				bank_movement_retention_position.accounting_retention_accounting_type_id = cash_bank_retention_accounting_type
				bank_movement_retention_position.amount_subject_retention = params[:subtotal_price_amount]
				bank_movement_retention_position.save
			end
			current_bank_movement_positions_clear
		end
	end

	def show
		@bank_movement = CashBank::BankMovement.find(params[:id])
		@bank = @bank_movement.cash_bank_bank
		@bank_movement_positions = @bank_movement.cash_bank_bank_movement_positions
		respond_to do |format|

				format.html
				format.pdf do
					@printed = @bank_movement.printed
					@bank_movement.update_attribute(:printed, true)
					render :pdf                            => "BancoMovements_#{@bank_movement.id.to_code}",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Portrait',
								 :page_size												=> 'Letter',
								 
								 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																				},
															:left => '2'
															},
								 :margin => {:top                => 13,
														 :bottom             => 20,
														 :right              => 2,
														 :left               => 5
													 }
				end
		end
	end

	def edit
    current_bank_movement_positions_clear
		@bank_movement = CashBank::BankMovement.find(params[:id])
		@bank = @bank_movement.cash_bank_bank
    @bank_movement.cash_bank_bank_movement_positions.each do |bank_movement_position|
      bank_movement_position[:id_temporal] = timestamp
      self.current_bank_movement_positions=bank_movement_position.attributes
    end
	end

	def update
		@bank_movement = CashBank::BankMovement.find(params[:id])
    @bank_movement.update_attributes(params[:cash_bank_bank_movement])
  end

	def set_bank_movement_operation_type
    
		@bank_movement_operation_type = CashBank::BankMovementOperationType.find_by_id(params[:cash_bank_bank_movement][:cash_bank_bank_movement_operation_type_id]) if params[:cash_bank_bank_movement]

		movement_external_doc_id = params[:movement_external_doc_id]
		movement_external_doc_type = params[:movement_external_doc_type]

		if @bank_movement_operation_type
			@accounting_accounting_concepts = @bank_movement_operation_type.associated_concepts
			unless movement_external_doc_id.empty?
				@involvement_types = @bank_movement_operation_type.associated_involvement_types_with_reference_document
				@document_reference_types = {eval(movement_external_doc_type).model_humanize_name => movement_external_doc_type}
			else
				@involvement_types = @bank_movement_operation_type.associated_involvement_types
				@document_reference_types = @bank_movement_operation_type.is_debit ? CashBank::BankMovement.document_reference_debit_types : CashBank::BankMovement.document_reference_credit_types
			end

			if !@bank_movement_operation_type.is_debit
				@supplier_owner = Supplier.find_owner
			end
		end
		
	end

	def set_accounting_concept
		@voucher = ""
		@bank = CashBank::Bank.find_by_id(params[:cash_bank_bank_movement][:cash_bank_bank_id])
		@bank_movement_operation_type = CashBank::BankMovementOperationType.find_by_id(params[:bank_movement_operation_type_id])
		@success = false
		if @bank
			@success = true
			@bank_accounts = @bank.cash_bank_bank_accounts
		end
	end

	def set_bank_account
		@bank_account = CashBank::BankAccount.find_by_id(params[:cash_bank_bank_movement][:cash_bank_bank_account_id])
		bank_movement_operation_type = CashBank::BankMovementOperationType.find_by_id(params[:bank_movement_operation_type_id])
		@success = false
		if @bank_account
			@success = true
			@checkbooks = []
			 if bank_movement_operation_type.require_check?
				@success &= @bank_account.used_checkbook?
				if @success
					@checkbooks = @bank_account.cash_bank_checkbooks
				end
			 end
		end
	end

	def set_check_number
		@checkbook = CashBank::Checkbook.find_by_id(params[:cash_bank_bank_movement][:cash_bank_checkbook_id])
		bank_movement_operation_type = CashBank::BankMovementOperationType.find_by_id(params[:bank_movement_operation_type_id])
		@voucher = @checkbook.next_check_number if @checkbook
	end

	def set_involvement_type
		@movement_external_doc_id = params[:movement_external_doc_id]
		@movement_external_doc_type = params[:movement_external_doc_type]
		@involvement_type = CashBank::InvolvementType.find_by_id(params[:cash_bank_bank_movement_position][:cash_bank_involvement_type_id])
	end

	def set_reference_document
		
		@errors = {}
		if !params[:reference_document_type].eql?("null")
			@reference_document = eval(params[:reference_document_type]).find_by_id(params[:cash_bank_bank_movement_position][:reference_document_id])
			if @reference_document
				if @reference_document.is_payable?
					@success = true
				else
					@errors[CashBank::BankMovement.human_attribute_name("reference_document").to_s] = "ya está contabilizado"
				end
			else
				@errors[CashBank::BankMovement.human_attribute_name("reference_document").to_s] = "no existe"
			end
		else
			@errors[CashBank::BankMovement.human_attribute_name("reference_document_type").to_s] = "no puede estar en blanco"
		end
	end

	def add_movement_position
    params[:cash_bank_bank_movement_position][:id_temporal] = timestamp
		@total_price = 0
		@bank_movement_position = CashBank::BankMovementPosition.new(params[:cash_bank_bank_movement_position])
		@success = @bank_movement_position.valid?
		if @success
			self.current_bank_movement_positions=params[:cash_bank_bank_movement_position]
			@total_price = current_bank_movement_positions_objects.map(&:amount).to_sum
		end
	end

	def remove_movement_position
		remove_current_bank_movement_positions(params[:id_temporal])
   
		@total_price = 0
    @total_price = current_bank_movement_positions_objects.map(&:amount).to_sum.to_f
	end

	def new_revert
		@bank_movement = CashBank::BankMovement.new
	end

	def set_movement_to_revert
		@bank_movement = CashBank::BankMovement.find_by_id(params[:bank_movement_id])
	end

	def revert
		@bank_movement = CashBank::BankMovement.find_by_id(params[:cash_bank_bank_movement][:id])
		result = @bank_movement.revert
		@bank_movement_revert = result[:object]
		@success = result[:success]
	end

	def movements_by_criterion
		@bank_accounts = CashBank::BankAccount.all
		@bank_movement_operation_type = CashBank::BankMovementOperationType.all_visibles
		@accounting_concept = Accounting::AccountingConcept.all
		@banks = CashBank::Bank.all
	end

	def process_movements_by_criterion
		@bank_movements = CashBank::BankMovement.all_by_criterion(params[:bank_movement])
		@date_from = params[:bank_movement][:date_from]
		@date_to = params[:bank_movement][:date_to]
					render :pdf                            => "BancoMovements",
								 :disposition                    => 'attachment',
								 :layout												 =>	'backend/contable_document.html.erb',
								 :orientation                    => 'Landscape',
								 :page_size												=> 'Letter',

								 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																				},
															:left => '2'
															},
								 :margin => {:top                => 13,
														 :bottom             => 20,
														 :right              => 2,
														 :left               => 5
													 }
	end


	def set_bank_accounts_by_criterion
		if params[:bank_movement][:bank].empty?
			@bank_accounts = CashBank::BankAccount.all
		else
			@bank_accounts = CashBank::Bank.find(params[:bank_movement][:bank]).cash_bank_bank_accounts
		end
	end
	
	protected


	def current_bank_movement_positions
		session[:current_bank_movement_positions].nil? ? [] : session[:current_bank_movement_positions]
	end

	def current_bank_movement_positions_objects
		@bank_movement_positions = []
		self.current_bank_movement_positions.each do |bank_movement_position|
			@bank_movement_positions << CashBank::BankMovementPosition.new(bank_movement_position)
		end
		@bank_movement_positions
	end

	def current_bank_movement_positions=bank_movement_position
    session[:current_bank_movement_positions] = (session[:current_bank_movement_positions].nil? ? [] : session[:current_bank_movement_positions])
		session[:current_bank_movement_positions].delete_if do |item|
			
			item["reference_document_id"].to_i.eql?(bank_movement_position[:reference_document_id].to_i) and !bank_movement_position[:reference_document_id].empty?
		end
		session[:current_bank_movement_positions] << bank_movement_position
	end

  def remove_current_bank_movement_positions(id_temporal)
    session[:current_bank_movement_positions].each do |item|
			session[:current_bank_movement_positions].delete(item) if item["id_temporal"].to_i.eql?(id_temporal.to_i)
    end
  end

	def current_bank_movement_positions_clear
		session[:current_bank_movement_positions] = []
	end


  def set_title
    @title = "Movimiento en Bancos"
  end
end
