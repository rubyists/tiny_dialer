p = ->
  window.console?.debug?(arguments)

formSupport = (type) ->
  i = document.createElement("input")
  i.setAttribute("type", type)
  i.type != "text"

dirtyRatio = false
dialerRatio = $('#dialer_ratio')
dialerRatioLabel = $('label[for="dialer_ratio"]')

showStats = (callback) ->
  $.get '/stats.json', (data) ->
    $('#show_ready_agents').text(data.ready_agents.length)
    $('#show_dialer_status').text(data.dialer_status)
    $('#show_ivr_status').text(data.ivr_status)
    $('#show_current_dials').text(data.current_dials.length)
    $('#show_aim').text(data.aim)
    dialerRatio.val(data.ratio) if dirtyRatio == false
    callback?.call()
    undefined

syncRatio = ->
  ratio = dirtyRatio
  if ratio != false
    $.post('/set_dialer_ratio', {ratio: ratio})
    dialerRatio.val(ratio)
    dirtyRatio = false

slideRatio = (event, ui) ->
  dirtyRatio = parseFloat(ui.value, 10)
  dialerRatio.val(dirtyRatio)
  undefined
  
$ ->
  setInterval(syncRatio,  1000)
  syncRatio()
  setInterval(showStats,  5000)

  if formSupport('range')
    dialerRatio.change( ->
      # only keep one decimal digit
      dirtyRatio = parseInt(parseFloat(dialerRatio.val(), 10) * 10, 10) / 10
      dialerRatioLabel.text("Currently #{dirtyRatio}")
    )
    showStats ->
      dirtyRatio = parseInt(parseFloat(dialerRatio.val(), 10) * 10, 10) / 10
      dialerRatioLabel.text("Currently #{dirtyRatio}")
  else
    showStats ->
      slider_args = {
        min: parseFloat(dialerRatio.attr('min'), 10),
        max: parseFloat(dialerRatio.attr('max'), 10),
        step: parseFloat(dialerRatio.attr('step'), 10),
        value: parseFloat(dialerRatio.val(), 10),
        slide: slideRatio,
      }
      $('#dialer_ratio_slider').slider(slider_args)

  if !formSupport('date')
    $('input[type="date"]').datepicker()
