# = require jquery
# = require jquery_ujs
# = require turbolinks
# = require jquery.raty
# = require bootstrap/transition
# = require bootstrap/dropdown
# = require bootstrap/collapse
# = require bootstrap/modal
# = require bootstrap-wysihtml5/b3
# = require bootstrap-wysihtml5/locales/zh-CN
# = require nprogress
# = require nprogress-turbolinks



$('#new_post').on('submit', ->
   if (!confirm("你只能上交一篇文章，且上交之后不能修改，你是否要继续提交?"))
    return false
)