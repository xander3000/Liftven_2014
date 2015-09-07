class Backend::FinancialManagement::CreditNotesController <  Backend::FinancialManagement::BaseController

	def index
		@credit_notes = CreditNote.all
	end

  def new
    @credit_note = CreditNote.new
    @client = Client.new
    @contact = Contact.new
    @standard_measures = StandardMeasure.all
    self.current_client_clear
    self.current_product_by_credit_notes_clear
  end

  def create
    @credit_note = CreditNote.new(params[:credit_note])
    product_by_credit_notes = self.current_product_by_credit_notes
    @success = @credit_note.valid?
    @success &= !product_by_credit_notes.empty?

    if @success
      @credit_note.save
      product_by_credit_notes.each do |product_by_credit_note|
        product_by_credit_note.credit_note = @credit_note
        product_by_credit_note.save
      end
      @credit_note.set_values_sub_total_total
			@credit_note.reload
			if(@credit_note.invoice.fiscal_printed?)
				@credit_note.print
			end
    end
  end

  def show
    @credit_note = CreditNote.find(params[:id])
    @product_by_credit_notes = @credit_note.product_by_credit_notes
		respond_to do |format|
      format.html
      format.pdf do
				render :pdf                            => "nota_credito_#{@credit_note.id}",
               :disposition                    => 'attachment',
							 :layout												 =>	'backend/contable_document.html.erb',
							 :page_size                      => 'Letter',
							 :margin => {:top                => 18,
                           :bottom             => 30,
													 :right              => 2,
                           :left               => 5
 												 },
							 :header => {:html => { :template => 'shared/backend/layouts/header_contable_document.erb'
																			},
														:left => '2'
														},
								:footer => {:html => { :template => 'shared/backend/layouts/footer_contable_document.erb'
																			},
														:left => '2'
														}
			end
		end
  end

  def search_invoices
    @invoices = []
    @credit_note_emision_type = CreditNoteEmisionType.find_by_id(params[:credit_note][:credit_note_emision_type_id])
    client = self.current_client
    @invoice_required = @credit_note_emision_type.invoice_required
    if @invoice_required and client #TODO: valdar que hacer si no ingresa el cliente
      @invoices = client.active_invoices
    end
  end

  def load_product_by_invoice
    @invoice = Invoice.find_by_id(params[:credit_note][:invoice_id])
    @product_by_credit_notes = product_by_credit_invoices = @invoice.product_by_invoices
     product_by_credit_invoices.each do |product_by_invoice|
      attributes_product_by_invoices = product_by_invoice.attributes
      attributes_product_by_invoices.delete("id")
      attributes_product_by_invoices.delete("invoice_id")
      self.current_product_by_credit_notes = attributes_product_by_invoices
    end
  end

  def add_product
    product_by_credit_note = ProductByCreditNote.new(params[:product])
    @success = product_by_credit_note.valid?
    if @success
      params[:product][:id_temporal] = timestamp
      self.current_product_by_credit_notes = params[:product]
    end
    @product_by_credit_notes = self.current_product_by_credit_notes
  end

  def remove_product
    self.remove_current_product_by_credit_notes(params[:id_temporal])
    @product_by_credit_notes = self.current_product_by_credit_notes
  end

  def set_current_client
    self.current_client = params[:client_id]
    puts "----------------"
    p params[:client_id]
    render :text => self.current_client
  end


  def current_product_by_credit_notes_clear
    session[:credit_notes_product_by_credit_notes] = []
  end

  def current_product_by_credit_notes=(product_by_credit_note)
    session[:credit_notes_product_by_credit_note] = [] if session[:credit_notes_product_by_credit_note].nil?
    session[:credit_notes_product_by_credit_note] << product_by_credit_note
  end

  def remove_current_product_by_credit_notes(id_temporal)
    session[:credit_notes_product_by_credit_note].each do |item|
    session[:credit_notes_product_by_credit_note].delete(item) if item[:id_temporal].to_i.eql?(id_temporal.to_i)
    end
  end

  def current_product_by_credit_notes
    product_by_credit_notes = []
    session[:credit_notes_product_by_credit_note].each do |item|
      puts item.keys
      product_by_credit_notes << ProductByCreditNote.new(item)
    end
    product_by_credit_notes
  end

  def current_product_by_credit_notes_clear
    session[:credit_notes_product_by_credit_note] = []
  end


    protected

  def set_title
    @title = "Notas de Crédito"
  end
end
