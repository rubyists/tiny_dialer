p = ->
  window.console?.debug?(arguments)

dirtyRatio = false

showStats = ->
  $.get '/stats.json', (data) ->
    p data

    $('#show_ready_agents').text(data.ready_agents.length)
    $('#show_dialer_status').text(data.dialer_status)
    $('#show_ivr_status').text(data.ivr_status)
    $('#show_current_dials').text(data.current_dials.length)
    $('#show_aim').text(data.aim)
    $("#dialer_ratio").val(data.ratio) if dirtyRatio == false
    undefined

syncRatio = ->
  ratio = dirtyRatio
  if ratio != false
    $.post('/set_dialer_ratio', {ratio: ratio})
    $('#dialer_ratio').val(ratio)
    dirtyRatio = false

slideRatio = (event, ui) ->
  dirtyRatio = parseFloat(ui.value, 10)
  $('#dialer_ratio').val(dirtyRatio)
  undefined
  
$ ->
  if location.pathname == "/"
    $('#dialer_ratio_slider').slider(
      min: 1.0,
      max: 10.0,
      step: 0.1,
      value: parseInt($('#dialer_ratio').val(), 10),
      slide: slideRatio,
    )

    setInterval(showStats,  5000)
    setInterval(syncRatio,  1000)
    showStats()

  $('.datepicker').datepicker()
