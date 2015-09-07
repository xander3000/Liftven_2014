// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



  $(document).ready(function(){ // Script del Navegador

    months = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    monthShort = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    weekdays = ['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'];
    weekdaysShort = ['Dom','Lun','Mar','Mié','Juv','Vie','Sáb'];
    weekdaysShortMin = ['Do','Lu','Ma','Mi','Ju','Vi','Sá'];

	/****TOOLTIP*******/
    $( document ).tooltip();
	 $("#main, #jqxMenu ul,#footer").click(function () {
		 $('.floating_box').hide()
	 });
	 $(".avatar").click(function () {
		 $('.floating_box').show()
	 });
    $("form").reset();
    $("button, input:submit,input:button,a.button ").button();
    $("ul.subnavegador").not('.selected').hide();
    $("a.down").click(function(e){
        var desplegable = $(this).parent().find("ul.subnavegador");
        $('.down').parent().find("ul.subnavegador").not(desplegable).slideUp('slow');
        desplegable.slideToggle('slow');
        e.preventDefault();
    })
    $.masked.definitions['~']='[VEJGvejg]';
	 $.masked.definitions['º']='[VEve]';
    $(".identification_document").masked("~-9999999?9-9");
	 $(".cedula").masked("º-99999999");
    $(".phone").masked("(9999) 999-9999").attr("size","12");
    $(".account_number").masked("9999-9999-99-9999999999");
    $(".account_number").masked("9999-9999-99-9999999999");
	 $(".datepicker").attr("readonly",true);
    amount_keypress();
	 uppercase_on_keypress();

    /****ANCHOR******/
    $('.goTop').attr("title","Ir al tope");
	 
    $('.goTop').click(function(){
        $('html,body').animate({scrollTop:'0px'}, 500);return false;
    });
    //$("#menunav a[title]").tooltip();
	 
    $(".block-item").click(function () {
        $(this).parent().children(".block-item").removeClass("selected");
        $(this).addClass("selected");
    });

		//selectMenu();
	});

jQuery.fn.strPadLeft = function(l,s) {
		var o = parseFloat($(this).val()).toString();
		if(isNaN(o))
			o = 0
		if (!s || isNaN(o))
			s = '0';

		while (o.length < l)
			o = s + o;
		$(this).val(o);
	};

  jQuery.fn.reset = function () {
    $(this).each (function() {this.reset();});
	}

  jQuery.fn.changeReference = function (reference) {
    $("."+reference).click().change();
	}

 jQuery.fn.endWith = function(stringCheck){
		myString =$(this).val()
	  //var foundIt = (myString.lastIndexOf(stringCheck) === myString.length - stringCheck.length) > 0;
		return myString[myString.length -1]
	 }

function resizeAllSelect(){
	$("select").each(function (index, domEle) {
		id = $(this).attr("id")
		width = $(this).css("width")
		$("#"+id+"-button").css("width",width);
	});
}


function selectMenu(){
	
		$( "select" ).selectmenu({
			change: function( event, ui ) {
				$(this).change();
			}
		});
	}



function alert_error(msg){
	$("#dialog-application-error-message").html("<span class='ui-icon ui-icon-alert' style='float: left; margin-right: .3em;' /><strong class=''>ATENCIÓN: </strong>"+msg);
	$("#dialog-application-error").dialog( "open" );
}

function amount_keypress(){
   $(".amount").keyup(function(event){
		  //if ( event.which == 44 || (event.which != 8 && event.which != 0 && (event.which < 48 || event.which > 57)))
		  if ( event.which == 44 )
                        event.preventDefault();
    }).addClass("right").attr("size","15");
}

function uppercase_on_keypress(){
	$(".uppercase").keyup(function(event){
	
		 $(this).val($(this).val().toUpperCase())
    })
}

function formatCurrency(valor) {
  	valor=valor.toFixed(2);
	valor=valor.toString();
	valor=valor.replace('.',',');
	valor=getFormat(valor);
	return (valor);
    }

    function getFormat(num,prefix)
    {

            var num2=num;
            prefix = prefix ||'';
            num2 +='';
            var splitStr = num2.split(',');
            var splitLeft = splitStr[0];
            var splitRight = splitStr.length > 1 ? ',' + splitStr[1] : '';
            var regx = /(\d+)(\d{3})/;
            while (regx.test(splitLeft))
            {
                    splitLeft = splitLeft.replace(regx, '$1' + '.' + '$2');
            }
            num = prefix + splitLeft + splitRight;

            return(num);
    }

        //holidays
    var natDays = [
      [1, 1, 've'],
      [2, 6, 've'],
      [4, 19, 've'],
      [5, 1, 've'],
      [6, 24, 've'],
      [7, 5, 've'],
      [7, 24, 've'],
      [10, 12, 've'],
      [12, 24, 've'],
      [12, 25, 've'],
      [12, 31, 've']
    ];


    function noWeekendsOrHolidays(date) {
        var noWeekend = $.datepicker.noWeekends(date);
        if (noWeekend[0]) {
            return nationalDays(date);
        } else {
            return noWeekend;
        }
    }
    function nationalDays(date) {
        for (i = 0; i < natDays.length; i++) {
            if (date.getMonth() == natDays[i][0] - 1 && date.getDate() == natDays[i][1]) {
                return [false, natDays[i][2] + '_day'];
            }
        }
        return [true, ''];
    }




