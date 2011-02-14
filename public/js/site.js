$(function(){
  $('.datepicker').datepicker();

  var setMaxUrl = $('.dialer_control form').attr('action')
  $("#dialer_pool_slider").slider({
    value: parseInt($('#dialer_max').val(), 10),
    min: 0,
    max: 200,
    step: 2,
    slide: function(event, ui) {
      $.post(setMaxUrl, {max: ui.value});
      $('#status_dialer_pool').text(ui.value);
      $("#dialer_pool").val(ui.value);
    }
  });
  $("#dialer_pool").val($("#dialer_pool_slider").slider("value"));
})
