class Frontend::BaseController < ApplicationController
  layout "frontend/application"
  helper_method :current_cart,:current_cart_subtotal


	def current_budget
		session[:frontend_budget] = {} if session[:frontend_budget].nil?
		Budget.new(session[:frontend_budget])
	end

	def current_budget=(budget)
		session[:frontend_budget] = budget
	end

  def current_budget_clear
    session[:frontend_budget] = {}
  end

  def current_cart
    session[:frontend_current_cart] = [] if session[:frontend_current_cart].nil?
    products_by_budget = []
    session[:frontend_current_cart].each do |item|
			product_by_budget = ProductByBudget.new(item)
      product_by_budget[:id_temporal] = item[:id_temporal]
			products_by_budget << product_by_budget
    end
    products_by_budget
  end

  def current_cart=(product_by_budget)
    session[:frontend_current_cart] = [] if session[:frontend_current_cart].nil?
    #product_by_budget[:id_temporal] = timestamp if product_by_budget[:id_temporal].nil?
    session[:frontend_current_cart] << product_by_budget
  end

  def current_cart_remove_item(id_temporal)
		#TODO: Quirtar los diseños asociados
     session[:frontend_current_cart].delete_if { |item| item[:id_temporal].to_s.eql?(id_temporal.to_s) }
  end

  def current_cart_subtotal
    subtotal = 0;
    session[:frontend_current_cart].each do |product_by_budget|
      subtotal += ProductByBudget.new(product_by_budget).total_price.to_f
    end
    subtotal
  end

  def  current_cart_clear
    session[:frontend_current_cart] = []
    current_session_design
  end
  
  def current_session_design
      key = DigitalCard::SESSION_KEY_REFERENCE
      session[key]
  end

  def current_session_design_clear
     key = DigitalCard::SESSION_KEY_REFERENCE
     session[key] = nil
  end
  
end
