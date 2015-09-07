class Backend::Cpanel::DigitalCardsController < Backend::Cpanel::BaseController
  def new
    @digital_card = DigitalCard.new
  end

  def create
    @digital_card = DigitalCard.new(params[:digital_card])
    @success = @digital_card.valid?
    if @success
      @digital_card.save
       flash[:notice] = "Tu registro ha sido guardado exitosamente!"
       redirect_to new_backend_cpanel_digital_card_url
    else
       flash[:error] = "Verifica los datos de entrada"
      render :action => "new"
    end

  end
end
