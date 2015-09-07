/* @version 1.0 lookupSeniat
 * @author Gabriel Plaza
 * @webSite: http://www.liftven.com
 * jquery search documento identification into SENIAT portal
 */
(function($){
    $.fn.lookupSeniat=function(options){
		 var options = $.extend({}, $.fn.lookupSeniat.defaults, options);
		 var identification_document = $(this);

		 identification_document.blur( function () {
			 
						  $(this).val($(this).val().toUpperCase())
						  var parent = $(this).parent();
						  
						  if(options.clearInput)
							$("#"+options.inputFullname).val('');

						  parent.append("<span>"+options.spinner+"</span>")
						  $(this).val($(this).val().toUpperCase())
						  letter_value = {"V" : 1,"E":2};
						  letter_key = {"1" : "V","2":"E"};
						  digit_value = [4,3,2,7,6,5,4,3,2];
						  document_identification = (letter_value[$(this).val()[0]]+$(this).val().substring(2))
                                                  document_identification = document_identification.split("-")[0]
						  validator_digit = 0;

						  $.each(document_identification.split(''),function( intIndex, objValue ){
							validator_digit += digit_value[intIndex]*parseInt(objValue)
						  });
							validator_digit = 11-validator_digit%11
							validator_digit = validator_digit > 9 ? 0 : validator_digit;
							document_identification_c = $(this).val().replace("-", "").replace("-", "");  //letter_key[document_identification[0]]+document_identification.substring(1)+validator_digit

						if(document_identification_c.length <= 9)
						  document_identification_c = document_identification_c+validator_digit
						$.ajax({
						  type: "POST",
						  url: options.urlSearch,
						  data: {doc: document_identification_c},
						  success:function(result){
                                                                
								 parent.find("span").remove()
								 if(result.success){
                                                                        $("#"+options.inputDocumentFiscalIdentification).val(result.data.document_fiscal_identification);
									$("#"+options.inputFullname).val(result.data.fullname).attr("readonly",true);
									$("#"+options.inputRateRetention).val(result.data.rate)
									$("#client_rate_retention").val(result.data.rate);
									if(result.data.taxpayer == "SI")
									 $("#"+options.inputIsTaxpayer).prop('checked', true);
								  else
									 $("#"+options.inputIsTaxpayer).prop('checked', false);
								 if(result.data.retention_agen == "SI")
								  	$("#"+options.inputIsRetentionAgent).prop('checked', true);
								 else
									$("#"+options.inputIsRetentionAgent).prop('checked', false);
								 $("#"+options.inputIsRetentionAgent).attr("readonly", true)
                                                                 if(options.blurEventInputFullname)
                                                                     $("#"+options.inputFullname).blur()
						  }
						 else{
							alert_error(result.message_error)
							$("#"+options.inputFullname).removeAttr("readonly")
						}
					  }
					});
				});
				return 1;
    }
    // Defaults jQuery(this).animate({width: 'show'}); jQuery(this).animate({width: 'hide'});
    $.fn.lookupSeniat.defaults = {
			 urlSearch: "/backend/base/document_identification_lookup_seniat",
			 inputFullname: "contact_fullname",
                         inputDocumentFiscalIdentification:"document_fiscal_identification",
			 inputRateRetention: "",
			 inputIsTaxpayer: "",
			 inputIsRetentionAgent: "",
			 spinner: "/images/icons/loader.gif",
			 clearInput: true,
			 api:false,
                         blurEventInputFullname:false
                         
    };


})(jQuery);
