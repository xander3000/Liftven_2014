class Backend::FinancialManagement::CustomerManagement::QuotesController < Backend::FinancialManagement::CustomerManagement::BaseController

	helper_method :current_positions

	def index
		@quotes = Crm::Quote.all
		@title = "CRM/Presupuestos"
	end

	def new
		current_positions_clear
		@quote = Crm::Quote.new
		@title = "CRM/Presupuestos/nuevo"
		default
	end

	def create
		@quote = Crm::Quote.new(params[:crm_quote])
		@success = @quote.valid?
		if @success
			@quote.save
			current_positions.each do |current_position|
				current_position.crm_quote = @quote
				current_position.save
			end
			@quote.set_values_sub_total_total
			current_positions_clear
		end
	end

	def show
		@quote = Crm::Quote.find(params[:id])
		@title = "CRM/Presupuestos/Detalle"
		@quote_positions = @quote.crm_quote_positions
	end

	def edit
		@quote = Crm::Quote.find(params[:id])
		@title = "CRM/Presupuestos/Editar"
	end

	def update
		@quote = Crm::Quote.find(params[:id])
		@success = @quote.update_attributes(params[:crm_quote])
	end

	def new_position
		@quote_position = Crm::QuotePosition.new
	end

	def add_position
		@quote_position = Crm::QuotePosition.new(params[:crm_quote_position])
		@success = @quote_position.valid?
		if @success
			@quote_position[:id_temporal] = timestamp
			self.current_positions=@quote_position.attributes
		end
		@quote_positions = current_positions
	end

	protected

  def current_positions
    quote_positions = []
    session[:quotes_quote_position].each do |item|
      quote_position = Crm::QuotePosition.new(item)
      quote_position[:id_temporal] = item[:id_temporal]
      quote_positions << quote_position
    end
    quote_positions
  end

	private

	def current_positions=(quote_position)
    session[:quotes_quote_position] = [] if session[:quotes_quote_position].nil?
    session[:quotes_quote_position] << quote_position
  end

  def remove_current_positions(id_temporal)
    session[:quotes_quote_position].each do |item|
			session[:quotes_quote_position].delete(item) if item[:id_temporal].to_i.eql?(id_temporal.to_i)
    end
  end



  def current_positions_clear
    session[:quotes_quote_position] = []
  end




	def default
		@quote.assigned_to = current_user
	end

end
