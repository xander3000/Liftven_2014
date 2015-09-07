class Accounting::AccountantAccount < ActiveRecord::Base
	def self.table_name_prefix
    'accounting_'
  end

	#ACCOUNTANT_ACCOUNT_FORMAT = "9.9.99.99.999"

	attr_accessor :parent_account_code

	humanize_attributes		:base => "Cuenta contable",
												:currency_type => "Moneda",
												:name => "Denominación",
												:fullname => "Denominaciòn completa",
												:code => "Cuenta",
												:open_date => "fecha apertura",
												:parent_account_code => "Cuenta Madre"


	has_many :accounting_accountant_accounts,:class_name => "Accounting::AccountantAccount",:foreign_key => "parent_account_id",:order => "code ASC"
	belongs_to :currency_type
	belongs_to :parent_account,:class_name => "Accounting::AccountantAccount"#,:foreign_key => "accounting_accountant_account_id"
	has_one :cash_bank_bank_account,:class_name => "CashBank::BankAccount",:foreign_key => "accounting_accountant_account_id"



	validates_format_of :code,:with => /\A([0-9].[0-9].[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9])\Z/i,:if => Proc.new { |accountant_account| AppConfig.accountant_account_level.eql?(5) }
	validates_format_of :code,:with => /\A([0-9].[0-9].[0-9][0-9].[0-9][0-9][0-9])\Z/i,:if => Proc.new { |accountant_account| AppConfig.accountant_account_level.eql?(4) }
	validates_presence_of :name,
												:fullname,
												:code,
												:currency_type,
												:open_date

	validates_uniqueness_of :code

	alias_attribute(:full_name, :fullname)


	#
	# Muestra la cuenta contable y su nombre
	#
	def code_with_name
		"#{code} -- (#{name})"
	end


	#
	# Verifica si es una cuenta final y no es padre de nadie
	#
	def is_final_account?
		accounting_accountant_accounts.empty?
	end

	#
	# Si usa chuequera
	#
	def used_checkbook?(add_error=true)
		if cash_bank_bank_account.nil?
			errors.add(:base, "no tiene asociado una cuenta bancaria")
			return false
		end

		if not cash_bank_bank_account.used_checkbook
			if add_error
				errors.add(:base, "Esta asociado a una cuenta bancaria sin chequera")
			end
			return false
		else
			return true
		end
	end

	#
	#Formato o mascara
	#
	def self.masked
		case AppConfig.accountant_account_level
		when 4
			"9.9.99.999"
		when 5
			"9.9.99.99.999"
		end
	end

	#
	# Busca las cuentas base o madres
	#
	def self.all_base
		all(:conditions => {:parent_account_id => 0})
	end

	#
	# BUsca por el campo dado para un autocomplete
	#
	def self.find_for_autocomplete(attr,value)
    rows = []
    items = all(:conditions => ["lower(#{attr}) LIKE lower(?) AND parent_account_id != ?","#{value}%",0],:limit => 10,:order => "code asc")
    items.each do |item|
      rows << {
                "value" => item[attr.to_sym],
                "label" => item[:fullname],
                "id" => item[:id],
                "name" => item[:name],
								"code" => item[:code],
                "code_response" => "ok"
              } if item.is_final_account?
    end
    if items.empty?
      rows = [{
          "value" => value,
          "label" => "Cuenta contable no registrada",
          "code_response" => "no-found"
          }]
    end
    JSON.generate(rows)
	end

	#
	# Import data
	#
	def self.import_data(src,separator=";")
		current_accountant_account_level = AppConfig.accountant_account_level
		currency = CurrencyType.default
		f = File.open(src, "r")
		f.each_line do |line|
			code,description = line.split(separator)
			a_code = code.strip.split("-")
			code = []
			index = 0
			
			a_code.each do |item|
				item = item.to_i

					case index
						when 0,1
							code  << item.to_code("01")
						when 2
							code  << item.to_code("02")
						when 3
							if current_accountant_account_level.eql?(4)
								code  << item.to_code("03")
							else
								code  << item.to_code("02")
							end
						when 4
							code  << item.to_code("03")
					end
					index +=1
			end
					code = code.join(".")
					case a_code.size
						when 1
							code = "#{code}.0.00.#{(current_accountant_account_level.eql?(4) ? "000" : "00.000")}"
							parent = 0
						when 2
							code = "#{code}.00.#{(current_accountant_account_level.eql?(4) ? "000" : "00.000")}"
							code_a = code.split(".")
							code_a = "#{code_a[0]}.0.00.#{(current_accountant_account_level.eql?(4) ? "000" : "00.000")}"
							
							parent = find_by_code(code_a)
							parent = parent ? parent.id : 0
							
						when 3
							code = "#{code}.#{(current_accountant_account_level.eql?(4) ? "000" : "00.000")}"
							code_a = code.split(".")
							code_a = "#{code_a[0]}.#{code_a[1]}.00.#{(current_accountant_account_level.eql?(4) ? "000" : "00.000")}"
							parent = find_by_code(code_a)
							parent = parent ? parent.id : 0
						when 4
							code_a = code.split(".")
							code_a = "#{code_a[0]}.#{code_a[1]}.#{code_a[2]}.#{(current_accountant_account_level.eql?(4) ? "000" : "00.000")}"
							parent = find_by_code(code_a)
							parent = parent ? parent.id : 0
						when 5
							code_a = code.split(".")
							code_a = "#{code_a[0]}.#{code_a[1]}.#{code_a[2]}.#{code_a[3]}.00"
							parent = find_by_code(code_a)
							parent = parent ? parent.id : 0
					end
				
					object = new
					object.name = description.strip.upcase
					object.fullname = "#{code.strip} - #{description.strip.upcase}"
					object.code = code.strip
					object.open_date = Time.now.to_date.to_s
					object.parent_account_id = parent
					object.currency_type = currency
					object.save
					object.errors.each do |a,b|
						p "#{a}  #{b}: #{object.code}"
					end
		end
		f.close
	end
end
