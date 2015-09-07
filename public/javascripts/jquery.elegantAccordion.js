jQuery.fn.elegantAccordion = function () {
  $(this).hover(
    function () {
        var $this = $(this);
        $this.removeClass("opacityUp");
        $this.stop().animate({'width':'480px'},500);
        $('.heading',$this).stop(true,true).fadeOut();
        $('.bgDescription',$this).stop(true,true).slideDown(500);
        $('.description',$this).stop(true,true).fadeIn();
    },
    function () {
        var $this = $(this);
        $this.addClass("opacityUp");
        $this.stop().animate({'width':'115px'},1000);
        $('.heading',$this).stop(true,true).fadeIn();
        $('.description',$this).stop(true,true).fadeOut(500);
        $('.bgDescription',$this).stop(true,true).slideUp(700);
    }
);
}
