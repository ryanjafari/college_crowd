form_wh = 'https://zapier.com/hooks/catch/n/4f9xr/'
email_wh = 'https://zapier.com/hooks/catch/n/4wpkh/'
confirm_page = 'confirm.html'

map =
  1:
    name: 'Help student-run Wildflour Bakery grow in Williamstown!'
    paypal:'https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=7XRCTUFS9RN2E&lc=US&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted'
    email: 'wildflourwilliamstown@gmail.com'
  2:
    name: 'An Intentional Community for a Committed Farm-to-Table Lifestyle'
    email: 'asb1@williams.edu'
  3:
    name: 'Skiing Across the World'
    email: 'benxcski@yahoo.com'
  4:
    name: '20 Seconds to a Better You and World'
    paypal: 'http://www.paypal.com/'
    email: 'gsc1@williams.edu'
  5:
    name: 'SincerelyEphs.org'
    paypal: 'http://www.paypal.com/'
    email: 'gsc1@williams.edu'
  6:
    name: 'InteracTiV: re-imagining multimedia as a social conversation'
    email: 'zhaoda.zhou@williams.edu,af5@williams.edu,irf1@williams.edu,10aae@williams.edu,piroune@gmail.com'
  7:
    name: 'Mental Illness Awareness for the Underprivileged'
    email: 'kla2@williams.edu'
  8:
    name: 'Learn2Earn: An educational fundraising platform'
    paypal: 'https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=W6FY479W4XKW8'
    email: 'rtm2@williams.edu'
  9:
    name: 'LocalCycle: Connecting Local Producers with Wholesale Buyers'
    email: 'kt1@williams.edu,samir.ghosh5291@gmail.com '
  10:
    name: 'Urban Unchained: Promoting sustainable urban living and people powered transportation'
    email: 'newton.davis@gmail.com'
  11:
    name: 'Breaking Barriers by Playing Professional Soccer in Kabul'
    email: 'npugliese33@gmail.com'
  12:
    name: 'The Banyan Project: Pioneering a new business model for web journalism'
    email: 'tom@tomstites.com'

$ ->
  ($ '.message-track').on 'click', message_track
  ($ '.back-track').on 'click', back_track

  project_code = querystring('project')

  if project_code.length > 0
    project_name = map[project_code].name
    project_paypal = map[project_code].paypal
    ($ '#project_name').text project_name
    ($ '#project_name_hidden').attr 'value', project_name
    if project_paypal
      ($ '#submit_button').text 'Next'
      ($ '#submit_message').show()
      ($ '#funds').hide()

  ($ '#pledge_form')
    .submit ->
      submit_form ($ @).serializeArray(), email_wh
      submit_form ($ @).serializeArray(), form_wh, (project_paypal || confirm_page)
      false
    .isHappy
      afterTestValid: refresh_validations
      submitButton: 'button[type=submit]'
      fields:
        'input[name=firstname]':
          required: true
          message: 'Your first name please!'
        'input[name=lastname]':
          required: true
          message: 'Your last name please!'
        'input[name=email]':
          required: true
          message: 'A real email address please!'
          test: happy.email
        'input[name=contribution]':
          required: true
          message: 'A tax-deductible contribution of at least $1.'
          test: happy.minValue
          arg: 1

refresh_validations = ->
  form = ($ '#pledge_form')
  cgs = form.find('.control-group')
  for cg in cgs
    cg = ($ cg)
    um = cg.find '.unhappyMessage'
    if um.length
      cg.addClass 'error'
    else
      cg.removeClass 'error'

submit_form = (data, webhook, redirect = null) ->
  request = $.ajax
    url: webhook
    type: 'post'
    dataType: 'jsonp'
    data: data

  request.always (jqXHR, textStatus) ->
    if jqXHR.status is 200
      console.debug '200'
      if redirect
        ga_send_event "Someone funded: #{data[0].value}"
        window.location.replace redirect
    else
      ga_send_event "Error with webhook: #{webhook}"

back_track = (e) ->
  project_code = ($ @).attr 'data-project'
  project_name = map[project_code].name
  ga_send_event "Someone backed: #{project_name}"
  window.location = "/williams/form.html?project=#{project_code}"
  false

message_track = (e) ->
  project_code = ($ @).attr 'data-project'
  project_name = map[project_code].name
  project_email = map[project_code].email
  ga_send_event "Message sent to: #{project_name}"
  window.location.href = "mailto:#{project_email}" if project_email
  false

ga_send_event = (label) ->
  console.debug "tracking beacon sent for: #{label}"
  ga 'send', 'event', 'button', 'click', label