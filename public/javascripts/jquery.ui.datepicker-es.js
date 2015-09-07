/* Inicialización en español para la extensión 'UI date picker' para jQuery. */
/* Traducido por Vester (xvester@gmail.com). */
jQuery(function($){

        months = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
        monthShort = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
        weekdays = ['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'];
        weekdaysShort = ['Dom','Lun','Mar','Mié','Juv','Vie','Sáb'];
        weekdaysShortMin = ['Do','Lu','Ma','Mi','Ju','Vi','Sá'];
	$.datepicker.regional['es'] = {
		closeText: 'Cerrar',
		prevText: '&#x3c;Ant',
		nextText: 'Sig&#x3e;',
		currentText: 'Hoy',
		monthNames: months,
		monthNamesShort: monthShort,
		dayNames: weekdays,
		dayNamesShort: weekdaysShort,
		dayNamesMin: weekdaysShortMin,
		weekHeader: 'Sm',
		dateFormat: 'dd/mm/yy',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: false,
		yearSuffix: ''
		};
		$.datepicker.setDefaults($.datepicker.regional['es']);
		
	  if($.timepicker != undefined){
		  $.timepicker.regional['es'] = {
				 timeOnlyTitle: 'Seleccione hora',
				 timeText: 'Tiempo',
				 hourText: 'Hora',
				 minuteText: 'Minutos',
				 secondText: 'Segundos',
				 currentText: 'Hoy',
				 closeText: 'Cerrar',
				 ampm: false
			};
			$.timepicker.setDefaults($.timepicker.regional['es']);
		}

	
   
/*
          Highcharts.setOptions({
              lang: {
                    rangeSelectorFrom: "Desde",
                    rangeSelectorTo: "Hasta",
                    rangeSelectorZoom: "Zoom",
                    months: months,
                    shortMonths: monthShort,
                    weekdays: weekdays
              }
        });*/



});