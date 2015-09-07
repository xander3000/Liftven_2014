// prototypal inheritance
if (typeof Object.create !== 'function') {
	Object.create = function (o) {
		function F() {}
		F.prototype = o;
		return new F();
	};
}

(function($){
	var DropList = function() {
                        
                        var selected,
			toggleClick = function(elem) {
                             jQuery(elem).click(function() {
                                $(".dropDownContainer dd ul").hide();
                                elem_parent = elem.parent(".dropDownContainer");
                                jQuery("dd",elem_parent).css({left:elem.offset().left - 68});
                                jQuery("dd ul",elem_parent).toggle();

                            });
			},
			elementItem = function(elem) {
                            elem_parent = elem.parent(".dropDownContainer");
                            jQuery("dd ul li a",elem_parent).hover(function() {
                                //$(this).addClass("ui-state-default");
                            });
                            jQuery("dd ul",elem_parent).mouseleave(function() {
                                $(".dropDownContainer dd ul").hide();
                                //$(".select_price:first").blur();
                                
                            });
                            jQuery("dd ul li input[type=checkbox]",elem_parent).click(function() {
                                jQuery("a.dropdown",elem_parent).removeClass("no-selected");
                                jQuery("a.dropdown",elem_parent).addClass("selected");
                                $(".select_price:first").blur();
                            });

                            jQuery("dd ul li a",elem_parent).click(function() {
                                
                                jQuery("a.dropdown",elem_parent).removeClass("no-selected");
                                jQuery("a.dropdown",elem_parent).addClass("selected");
                                if(!$(this).hasClass("no-hide"))
                                    $(".dropDownContainer dd ul").hide();
                                    

                                jQuery("dd ul li a.selected",elem_parent).removeClass("selected");
                                selected = $(this).attr("rel");
                                selected_id = $(this).attr("rev");
                                $("input[name='"+selected_id+"']").val(selected);
                                if($(this).attr("accesskey") != undefined){
                                  $.ajax({
                                          type: "POST",
                                          url: $(this).attr("accesskey"),
                                          data:  {value : selected},
                                          success: function() { $(".select_price:first").blur(); }
                                  });
                                }
                                else
                                    {
                                        $(".select_price:first").blur();
                                    }
                                $(this).addClass("selected");
                                
                            });
			};
		return {
			init: function(el) {
                        elem = el;
			toggleClick(elem);
			elementItem(elem);
			}
		};
	}();
	$.fn.droplist = function(options) {

            return this.each(function() {
			var obj = Object.create(DropList);
			DropList.init($(this));
                        $.data(this, 'droplist', obj);
			
		});

                //alert((this).html());
                //alert(1);
		//dropList.init($(this));
	};
	//$(document).ready(dropList.init);
})(jQuery);
