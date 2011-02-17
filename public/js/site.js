(function() {
  var dirtyRatio, p, showStats, slideRatio, syncRatio;
  p = function() {
    var _ref;
    return (_ref = window.console) != null ? typeof _ref.debug == "function" ? _ref.debug(arguments) : void 0 : void 0;
  };
  dirtyRatio = false;
  showStats = function() {
    return $.get('/stats.json', function(data) {
      p(data);
      $('#show_ready_agents').text(data.ready_agents.length);
      $('#show_dialer_status').text(data.dialer_status);
      $('#show_ivr_status').text(data.ivr_status);
      $('#show_current_dials').text(data.current_dials.length);
      $('#show_aim').text(data.aim);
      if (dirtyRatio === false) {
        $("#dialer_ratio").val(data.ratio);
      }
      return;
    });
  };
  syncRatio = function() {
    var ratio;
    ratio = dirtyRatio;
    if (ratio !== false) {
      $.post('/set_dialer_ratio', {
        ratio: ratio
      });
      $('#dialer_ratio').val(ratio);
      return dirtyRatio = false;
    }
  };
  slideRatio = function(event, ui) {
    dirtyRatio = parseFloat(ui.value, 10);
    $('#dialer_ratio').val(dirtyRatio);
    return;
  };
  $(function() {
    if (location.pathname === "/") {
      $('#dialer_ratio_slider').slider({
        min: 1.0,
        max: 10.0,
        step: 0.1,
        value: parseInt($('#dialer_ratio').val(), 10),
        slide: slideRatio
      });
      setInterval(showStats, 5000);
      setInterval(syncRatio, 1000);
      showStats();
    }
    return $('.datepicker').datepicker();
  });
}).call(this);
