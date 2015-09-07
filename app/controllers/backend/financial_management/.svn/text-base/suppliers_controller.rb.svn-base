class Backend::FinancialManagement::SuppliersController < Backend::FinancialManagement::BaseController
	helper_method :current_supplier_withholding_taxes

	def index
		@title = "Acreedores"
		@suppliers = Supplier.all(:conditions => {:active => true})
	end

	def new
		@title = "Acreedores/ Nuevo acreedor"
		@supplier = Supplier.new
		@contact = Contact.new
		current_supplier_withholding_taxes_clear
	end

	def create
		@supplier = Supplier.new(params[:supplier])
		@contact = Contact.new(params[:contact])
		
		@success =  @supplier.valid?
		@contact.valid?
    if @contact.exist?
      @contact = Contact.find_by_identification_document(@contact.identification_document)
      @success &=  @contact.update_attributes(params[:contact])
    else
      @success &=  @contact.valid?
			@contact.associated_with_supplier
    end
		if @contact.is_supplier?
			@success = false
			@contact.errors.add(:base,"ya esta asociado a un acreedor")
		end
		
		if @success
			if @contact.exist?
         @contact.associante_and_create_contact_categories(ContactType.supplier)
				else
          @contact.save
			end

      @contact.supplier.update_attributes(params[:supplier])
      @supplier = @contact.supplier
      @supplier.set_value_is_natural
			current_supplier_withholding_taxes.each do |withholding_taxes|
				withholding_taxes.supplier = @supplier
				withholding_taxes.save
			end
			current_supplier_withholding_taxes_clear
		end
	end

	def show
		@title = "Acreedores/ Detalle acreedor"
		current_supplier_withholding_taxes_clear
		@supplier = Supplier.find(params[:id])
		@contact = @supplier.contact
		@payable_accounts = @supplier.accounting_payable_accounts
    @incoming_invoices = @supplier.account_payable_incoming_invoices
		@supplier_withholding_taxes = @supplier.supplier_withholding_taxes
    @supplier_credit_notes = @supplier.account_payable_supplier_credit_notes
	end

	def edit
		@title = "Acreedores/ Editar acreedor"
		current_supplier_withholding_taxes_clear
    
		@supplier = Supplier.find(params[:id])
		@contact = @supplier.contact
    @supplier_withholding_taxes = @supplier.supplier_withholding_taxes
    @supplier_withholding_taxes.each do |supplier_withholding_tax|
      self.current_supplier_withholding_taxes=supplier_withholding_tax.attributes
    end
	end

	def update
		@supplier = Supplier.find(params[:id])
		@success = @supplier.update_attributes(params[:supplier])
    @success &= @supplier.contact.update_attributes(params[:contact])
    current_supplier_withholding_taxes.each do |withholding_taxes|
				withholding_taxes.supplier = @supplier
				withholding_taxes.save
			end
			current_supplier_withholding_taxes_clear
	end

	def new_withholding_tax
		@supplier_withholding_tax = SupplierWithholdingTaxe.new
		added = current_supplier_withholding_taxes.map(&:accounting_withholding_taxe_type_id)
		@withholding_taxe_types = Accounting::WithholdingTaxeType.all_by_identification_document_type(params[:identification_document_type],:ignore => added)
	end

	def add_withholding_tax
		@supplier_withholding_tax = SupplierWithholdingTaxe.new(params[:supplier_withholding_taxe])
		@success = @supplier_withholding_tax.valid?
		if @success
			@supplier_withholding_tax[:id_temporal] = timestamp
			self.current_supplier_withholding_taxes=@supplier_withholding_tax.attributes
		end
		@supplier_withholding_taxes = current_supplier_withholding_taxes
	end

	def associate_credit_note
		@supplier = Supplier.find(params[:supplier_id])
		@supplier_credit_note = AccountPayable::SupplierCreditNote.new
		default_associate_credit_note
	end

	def process_associate_credit_note
		@supplier = Supplier.find(params[:supplier_id])
		@supplier_credit_note = AccountPayable::SupplierCreditNote.new(params[:account_payable_supplier_credit_note])
		default_associate_credit_note
		@success = @supplier_credit_note.valid?
		if @success
			@supplier_credit_note.save
		end
	end


	protected

	def default_associate_credit_note
			@supplier_credit_note.create_by = current_user
			@supplier_credit_note.supplier = @supplier
			@supplier_credit_note.posting_date = Time.now.to_date
			@supplier_credit_note.tax = AppConfig.tax
	end

	def current_supplier_withholding_taxes
		supplier_withholding_taxes = []
		session[:supplier_withholding_taxes].each do |item|
      supplier_withholding_tax = SupplierWithholdingTaxe.new(item)
      supplier_withholding_tax[:id_temporal] = item[:id_temporal]
      supplier_withholding_taxes << supplier_withholding_tax
    end
    supplier_withholding_taxes
	end

	private

	def current_supplier_withholding_taxes=(supplier_withholding_tax)
    session[:supplier_withholding_taxes] = [] if session[:supplier_withholding_taxes].nil?
    session[:supplier_withholding_taxes] << supplier_withholding_tax
  end

  def remove_current_supplier_withholding_taxes(id_temporal)
    session[:supplier_withholding_taxes].each do |item|
			session[:supplier_withholding_taxes].delete(item) if item[:id_temporal].to_i.eql?(id_temporal.to_i)
    end
  end



  def current_supplier_withholding_taxes_clear
    session[:supplier_withholding_taxes] = []
  end

end
