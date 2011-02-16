$(function(){
  $('.datepicker').datepicker();

  var setMaxUrl = '/set_dialer_max',
      setRatioUrl = '/set_dialer_ratio',
      originalPool = parseInt($('#dialer_pool').val(), 10),
      originalRatio = parseFloat($('#dialer_ratio').val(), 10);

  $("#dialer_pool_slider").slider({
    value: originalPool,
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

  $('#dialer_ratio_slider').slider({
    value: originalRatio,
    min: 1.0,
    max: 10.0,
    step: 0.1,
    slide: function(event, ui){
      var ratio = parseFloat(ui.value, 10);
      $.post(setRatioUrl, {ratio: ratio});
      $('#status_dialer_ratio').text(ratio);
      $('#dialer_ratio').val(ratio);
    }
  });
  $('#dialer_ratio').val($('#dialer_ratio_slider').slider('value'));
})
