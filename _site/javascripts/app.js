(function($){  
    $(function(){
        $.waypoints.settings.scrollThrottle = 30;

        $('#nav').waypoint(function(event, direction) {
            $(this).parent().toggleClass('sticky', direction === "down");
            event.stopPropagation();
        });

        // http://www.zachstronaut.com/posts/2009/01/18/jquery-smooth-scroll-bugs.html
        var scrollElement = 'html, body';
        $('html, body').each(function () {
            var initScrollTop = $(this).attr('scrollTop');
            $(this).attr('scrollTop', initScrollTop + 1);
            if ($(this).attr('scrollTop') == initScrollTop + 1) {
                scrollElement = this.nodeName.toLowerCase();
                $(this).attr('scrollTop', initScrollTop);
                return false;
            }    
        });

        $("a[href^='#']").click(function(event) {
            event.preventDefault();

            var $this = $(this),
            target = this.hash,
            $target = $(target);

            $(scrollElement).stop().animate({
                'scrollTop': $target.offset().top
            }, 500, 'swing', function() {
                window.location.hash = target;
            });
        });
    });
})(jQuery);
