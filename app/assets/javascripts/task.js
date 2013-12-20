function scrollSticky(e) {
    var t = $(window).scrollTop();
    var tmp = $("#task").height();
    var o = 0.85 - t*1.414/tmp;
    $("#task").css({
        opacity: o,
        bottom: -t
    });
}

//var n = $("#task").height();
var n = 30;
$(document).scroll(function() {
    scrollSticky(n)
});