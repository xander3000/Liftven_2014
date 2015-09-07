/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

function show_common_menu()
{
    $("#venom-top").css("margin-top","310px");
    $("#venom-common-menu").css("height","233px");
    $("#venom-common-menu").css("visibility","visible");
    if(!$("#venom-common-menu").is(":visible"))
      $("#venom-common-menu").show('blind');
}

function hide_common_menu()
{
    $("#venom-common-menu").css("visibility","hidden");
    $("#venom-common-menu").css("height","1px");
    $("#venom-top").css("margin-top","74px");
    $("#venom-common-menu").hide('blind');
}

function submit_current_form(form_name){
    $("#"+form_name).submit();
}


 $(document).ready(function(){ // Script del Navegador


    /****ANCHOR******/
    $('.goTop').attr("title","Ir al tope");
    $('.goTop').click(
          function()
          {
                $('html,body').animate({scrollTop:'0px'}, 500);return false;
          }
    );
     $("a.external[rel]").overlay({
		mask: '#000',
		onBeforeLoad: function() {
                    var wrap = this.getOverlay().find(".contentWrap");
                    wrap.load(this.getTrigger().attr("href"));
                    this.getOverlay().addClass("custom");
		},
                onBeforeClose: function() {
                    this.getOverlay().removeClass("custom");
		}
	});


});





