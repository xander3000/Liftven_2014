class PaymentMethodType < ActiveRecord::Base

  TARJETA_CREDITO = "credit_card"
	TARJETA_DEBITO = "debit_card"
  TRANSFERENCIA_DEPOSITO = "transfer_deposit_bank"
  ABONO_CUENTA = "account"
  CHEQUE  = "check"
	EFECTIVO = "cash"
	CREDITO_45_DIAS = "credit_45_days"
	DEFAULT = EFECTIVO

	#named_scope :all_online_web, :conditions => ["tag_name IN (?)",self.all_online]

  #
  # Metodos de pagos por cobrar
  #
  def self.all_receivable
    [CHEQUE,CREDITO_45_DIAS]
  end

  #
  # Metodos de pagos por cobrar
  #
  def self.all_ready_cash
    [EFECTIVO,TARJETA_CREDITO,TARJETA_DEBITO]
  end

	#
  # Metodos de pagos online
  #
  def self.all_online
    [TRANSFERENCIA_DEPOSITO,ABONO_CUENTA]
  end

	#
  # Metodos para cierre de caja
  #
  def self.all_by_daily_cash_closing
    [EFECTIVO,TARJETA_CREDITO,TARJETA_DEBITO,CHEQUE,TRANSFERENCIA_DEPOSITO]
  end

	#
	# Instancias de de pagos online
	#
	def self.find_all_online
		all(:conditions => ["tag_name IN (?)",all_online])
	end

	#
	# Instancias para cierre de caja
	#
	def self.find_all_by_daily_cash_closing
		all(:conditions => ["tag_name IN (?)",all_by_daily_cash_closing])
	end

  #
  # Returna true si el medio de pago es tarjeta de credito o debito
  #
  def is_credit_debit_card?
    tag_name.eql?(TARJETA_CREDITO) or tag_name.eql?(TARJETA_DEBITO)
  end

  #
  # Returna true si el medio de pago es deposito o transferencia
  #
  def is_transfer_deposit_bank?
    tag_name.eql?(TRANSFERENCIA_DEPOSITO)
  end

  #
  # Returna true si el medio de pago es uso de abono a cuenta
  #
  def is_account?
    tag_name.eql?(ABONO_CUENTA)
  end

  #
  # Returna true si el medio de pago es uso de cheque
  #
  def is_check?
    tag_name.eql?(CHEQUE)
  end

	#
	# returna el objeto por defecto
	#
	def self.default
		find_by_tag_name(DEFAULT)
	end


end
