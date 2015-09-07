class Backend::FinancialManagement::PaymentOrdersController < Backend::FinancialManagement::BaseController
  def index
    @title = "Ordenes de pago"
		 @payment_orders = AccountPayable::PaymentOrder.all
  end

  def new
      @title = "Ordenes de pago / Nueva orden de pago"
      @payment_order = AccountPayable::PaymentOrder.new
      @bank_movement_operation_types = CashBank::BankMovementOperationType.all_visibles_debit
      default
  end

	def new_payment_order_from_payable_account
			payable_account = Accounting::PayableAccount.find_by_id(params[:payable_account_id])
			@title = "Ordenes de pago / Nueva orden de pago por cuenta por pagar #{payable_account.id.to_code}"
      @payment_order = AccountPayable::PaymentOrder.new
			
			@payment_order.external_doc_id = payable_account.doc_id
			@payment_order.external_doc_type = payable_account.doc_type
			@payment_order.description = "#{payable_account.note}/#{payable_account.doc.description}"
      @bank_movement_operation_types = CashBank::BankMovementOperationType.all_visibles_debit
			@accounting_concepts = Accounting::AccountingConcept.all_per_bank_debit
			@payment_order_document_types = AccountPayable::PaymentOrderDocumentType.all_by_tag_name(AccountPayable::PaymentOrderDocumentType::INCOMING_INVOICE)
      default
			render :action => :new
	end

	def create
      @payment_order = AccountPayable::PaymentOrder.new(params[:account_payable_payment_order])
      default
			@success = @payment_order.valid?
			if @success
				@payment_order.save
			end
	end

	def show
		@title = "Ordenes de pago / Orden de pago"
		@payment_order = AccountPayable::PaymentOrder.find(params[:id])
	end


  def set_payment_order_type
		payment_order_external_doc_id = params[:payment_order_external_doc_id]
		payment_order_external_doc_type = params[:payment_order_external_doc_type]
		
    @accounting_concept = Accounting::AccountingConcept.find_by_id(params[:account_payable_payment_order][:accounting_accounting_concept_id])
		unless payment_order_external_doc_id.empty?
			@external_doc = eval(payment_order_external_doc_type).find(payment_order_external_doc_id)
			@involvement_types = @accounting_concept.associated_involvement_types_with_reference_document
		else
			@involvement_types = @accounting_concept.associated_involvement_types if @accounting_concept
		end
  end

  def set_bank
    @bank = CashBank::Bank.find_by_id(params[:account_payable_payment_order][:cash_bank_bank_id])
		@success = false
		if @bank
			@success = true
			@bank_accounts = @bank.cash_bank_bank_accounts
		end
  end

	def set_bank_account
		@bank_account = CashBank::BankAccount.find_by_id(params[:account_payable_payment_order][:cash_bank_bank_account_id])
		@success = false
		if @bank_account
			@success = true
		end
	end

  def set_payment_order_document_type

    @payment_order_document_type =  AccountPayable::PaymentOrderDocumentType.find_by_id(params[:account_payable_payment_order][:account_payable_payment_order_document_type_id])
  end



	def set_reference_document
		@errors = {}
		@reference_document = eval(params[:reference_document_type]).find_by_id(params[:account_payable_payment_order][:doc_id])
		if @reference_document
			if @reference_document.is_payable?
				@success = true
          @total = @reference_document.total_amount
			else
				@errors[AccountPayable::PaymentOrder.human_attribute_name("doc_id").to_s] = "ya está contabilizado"
			end
		else
			@errors[AccountPayable::PaymentOrder.human_attribute_name("doc_id").to_s] = "no existe"
		end
	end

  def set_bank_movement_operation_type
    @bank_movement_operation_type = CashBank::BankMovementOperationType.find_by_id(params[:account_payable_payment_order][:cash_bank_bank_movement_operation_type_id])
    @bank_account = CashBank::BankAccount.find_by_id(params[:bank_account_id])
    if @bank_account
      
      @checkbooks = @bank_account.cash_bank_checkbooks
    end

  end

  def set_check_number
		@checkbook = CashBank::Checkbook.find_by_id(params[:account_payable_payment_order][:cash_bank_checkbook_id])
		@voucher = @checkbook.next_check_number if @checkbook
	end


    def default
      @payment_order.posting_date = Time.now.to_date
			@payment_order.create_by = current_user
    end
end
