require 'net/http'
require 'rexml/document'


module Screen
#	require "monitor"
#	def console(txt)
#		p txt
#		logger.info txt
#	end
end


module MyStringExtensions
	include ActionView::Helpers::UrlHelper
	include ActionView::Helpers::TagHelper
 def currency_to_float
     string = self.clone
		 factor = 1
			if string.include?("-")
	
				factor = -1
			end
      string.gsub!(/[^\d.,]/,'')          # Replace all Currency Symbols, Letters and -- from the string

      if string =~ /^.*[\.,]\d{1}$/       # If string ends in a single digit (e.g. ,2)
        string = string + "0"             # make it ,20 in order for the result to be in "cents"
      end

      unless string =~ /^.*[\.,]\d{2}$/   # If does not end in ,00 / .00 then
        string = string + "00"            # add trailing 00 to turn it into cents
      end

      string.gsub!(/[\.,]/,'')            # Replace all (.) and (,) so the string result becomes in "cents"
      string.to_f / 100 * factor                  # Let to_float do the rest
   end
  def to_underscore
    self.gsub(/ /, '_').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
	def to_demodulize
		self.tableize.split("/").last
	end
	def to_default_date(pattern="-")
		date = self.split(pattern)
		date.reverse.join("/")
	end
	def from_format_to_float(format,decimal=100)
		case format
			when "DDDDdd"
				self.to_f/decimal
		when "DDDD,dd","DDDD.dd"
				self.currency_to_float
		end
	end
	def from_format_to_date(format,separator="/")
		case format
			when "ddmmyyyy"
				self.rjust(8,'0').insert(2,separator).insert(5,separator)
		else 
				self
		end
	end
	def to_link(url)
		link_to(self,eval(url))
	end

end
 # include the extension
 String.send(:include, MyStringExtensions)

 module MyFloatExtensions
  include ActionView::Helpers
   def to_currency(with_unit=true)
      string = self.to_s.clone
      string = number_to_currency(string,:delimiter => ".", :separator => ",", :unit => with_unit ? "Bs" : "")
      string.strip
   end
   def to_currency_without_separators
      string = self.to_s.clone
      string = number_to_currency(string,:delimiter => "", :separator => "", :unit =>"")
      string.strip
   end
	def to_word
		completed = self.round(2)
		int,decimal = completed.to_s.split(".")
		if decimal.to_i.zero?
			"#{completed.to_words.capitalize} exactos"
		else
			"#{completed.to_words.capitalize} con #{decimal}/100"
		end
		
	end
 end
 # include the extension
 Float.send(:include, MyFloatExtensions)
 BigDecimal.send(:include, MyFloatExtensions)

 module MyFixnumExtensions
   def to_code(format="05")
     "%#{format}d" % self
   end
 end

 Fixnum.send(:include, MyFixnumExtensions)

 module MyArrayExtensions
	 def to_sum
		 self.inject{|sum,x| sum + x }
	 end
 end

 Array.send(:include, MyArrayExtensions)



  module MyTimeExtensions
    include ActionView::Helpers
		include ActionView::Helpers::TranslationHelper
   def months_since_to_now(since)
     count = 0
     months = []
     months << (l self.months_since(since),:format => :only_month)
     current = self.months_since(since).next_month
     since.times do 
       months << (l current,:format => :only_month)
       current = current.next_month
     end
     months
   end
	 def to_date(options={})
     l self,:format => :default_date
   end
   def time(options={})
     l self,:format => :default_time
   end
 end

Time.send(:include, MyTimeExtensions)

module ActionView
  module Helpers
    module PrototypeHelper
      class JavaScriptGenerator
        module GeneratorMethods
          include ActionView::Helpers::FormHelper
          # muestra mensajes de error y notificaciones
          # oculta el mensaje de progreso
          # habilita las acciones
          # example: page.ready
          def ready(flash,objects,id_subfix)
            objects = [objects] if not objects.kind_of?(Array)

            #show_notice(flash,id_subfix)
            show_errors(objects,id_subfix,flash)

          end

          # resetea los hidden inputs del formulario, los mensajes de validaciones en linea
          # y elimina los flash messages
          # example: page.reset(controller.controller_name,page.get_model_name(@case))
          def reset(controller_name, model)

          end

          # example: page.show_notice(flash,controller.controller_name)
          def show_notice(flash,id_subfix)
            #page.hide "notice_#{id_subfix}"
            unless flash[:notice].nil?
              page.replace_html "message_overlay",  :partial => "shared/modal_notice",:locals => {:messages => flash[:notice]}
            end
          end

          # example: page.show_errors(@case,controller.controller_name)
          def show_errors(objects,id_subfix,flash)
            #resetea los mensajes de error
           
            #page.hide "error_#{id_subfix}"
            
            messages = []
            objects.each do |object|
              model = object.class.to_s.classify.constantize if !object.kind_of?(String)
              model = object.to_s.classify.constantize if object.kind_of?(String)
              object = nil if object.kind_of?(String)

              if !object.nil?
                if object.respond_to?("errors")
                  unless object.errors.empty?
                    #object_name = page.get_model_name(object)
                    object.errors.each do |attr,msg|
                      #if !model.columns_hash[attr].nil?
                        messages << "<b>#{model.human_attribute_name(attr)}</b>: #{msg}"
                      #end
                    end

                  end
                end
              end

            end

           page.replace_html "message_overlay",  :partial => "shared/modal_errors",:locals => {:messages => messages}

#            if not flash[:error].nil?
#              if not flash[:error].empty?
#                flash[:error].each { |e| messages << "- #{e}<br/>" }
#              end
#            end

#            if not messages.blank?
#              page << "window.scrollTo(0, 0);"
#              page.replace_html "error_messages_#{id_subfix}", messages.join("<br/>")
#              page.show "error_#{id_subfix}"
#            end

          end
					
          def show_message_errors(objects,id_subfix,flash)
							messages = []
							objects.each do |attr,msg|
									messages << "<b>#{attr}</b>: #{msg}"
							end
						 page.replace_html "message_overlay",  :partial => "shared/modal_errors",:locals => {:messages => messages}
          end

					def show_flash_message_error(message)
						page << "$.notifyBar({
                html: '#{message}',
                delay: 3000,
                animationSpeed: 'normal',
                cls: 'error'
              });"
					end

        end
      end
    end
  end
end

class PaginationListLinkRenderer < WillPaginate::LinkRenderer
    def page_link(page, text, attributes = {})
			if @options[:remote]
				@template.link_to_remote text, :url => url_for(page), :html => attributes
			else
				@template.link_to text, url_for(page), attributes
			end
    end
  end

#Translate booleans
module I18n
  class << self
    alias :__translate :translate #  move the current self.translate() to self.__translate()
     alias :t :translate
     def translate(key, options = {})
       if key.class == TrueClass || key.class == FalseClass
         return key ? self.__translate("boolean.true", options) : self.__translate("boolean.false", options)
       else
         return self.__translate(key, options)
       end
     end
  end
end

 #Hacks
 class String
  alias_method :old_upcase, :upcase
  def upcase
    self.gsub( /\303[\240-\277]/ ) do
      |match|
      match[0].chr + (match[1] - 040).chr
    end.old_upcase
  end

  alias_method :old_downcase, :downcase
  def downcase
    self.gsub( /\303[\200-\237]/ ) do
      |match|
      match[0].chr + (match[1] + 040).chr
    end.old_downcase
  end
end
