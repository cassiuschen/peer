set = ($pos) ->
  $pos.prevAll().html('&#xe006;').addClass("active")
  $pos.html('&#xe006;').addClass("active")
  $pos.nextAll().html('&#xe007;').removeClass("active")

set_score = ($e, score) ->
  if score > 0
    set($e.children().eq(score - 1))
  else
    $e.children().html('&#xe007;').removeClass("active")

reset = ($e) ->
  score = parseInt($e.attr("data-score"))
  set_score($e, score)

$('[data-toggle="raty"]').each (i, e) ->
  reset($(e))

$('[data-toggle="raty"]:not([disabled])').on 'mouseenter', '.rate', (e) ->
  set($(this))
.mouseleave (e) ->
  reset($(this))
.on 'click', '.rate', (e) ->
  $this = $(this)
  $parent = $this.parent()
  score = $this.index() + 1
  $parent.addClass("hover")
  $parent.attr("data-score", score)
  $($parent.attr("data-input")).val(score).change()
  return false;