class Frontend::StaticContentsController < Frontend::BaseController


  def about_us
    @title = "¿Quienes Somos?"
  end

  def contact_us
    @title = "Contacto NetPrint"
  end

  def contact_us_email
    
  end

  def jobs
    @title = ""
  end

  def services
    @title = "Servicios"
  end

  def services_2
    @title = "Servicios"
  end

  def portfolio
     @title = "Portafolio"
		 @portfolio = WebPage::Portfolio.last
  end

  def price_list
     @title = "Lista de Precios"
  end



end
