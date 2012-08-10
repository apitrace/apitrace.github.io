(function($){  
    $(function(){
        $.waypoints.settings.scrollThrottle = 30;

        $('#nav').waypoint(function(event, direction) {
            $(this).parent().toggleClass('sticky', direction === "down");
            event.stopPropagation();
        });

        // The same for all waypoints
        $('body').delegate('section', 'waypoint.reached', function(event, direction) {
            var $active = $(this);

            if (direction === "up") {
                $active = $active.prev();
            }

            if (!$active.length) {
                $active = $active.end();
            }

            $('.active').removeClass('active');

            var id = $active.attr('id');
            var n = id.indexOf('-');
            if (n > -1) {
                var parent = id.substr(0, n);
                $('a[href=#'+parent+']').parent().addClass('active');
            }

            $('a[href=#'+id+']').parent().addClass('active');
        });

        $('section').waypoint({ offset: '10%' });

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
