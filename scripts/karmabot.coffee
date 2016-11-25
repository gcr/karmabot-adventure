# Description:
#   Karmabot scripts
#
# Notes:
#   Scripting documentation for hubot can be found here:
#   https://github.com/github/hubot/blob/master/docs/scripting.md

child_process = require 'child_process'
ansiparser = require 'node-ansiparser'

config = {
  room_name: process.env.ROOM_NAME
  frotz_path: "bocfel-0.6.3.2/bocfel"
  frotz_cmd: [process.env.IF_FILE]
}

new_process = (cmd, argv, send) ->
  proc = child_process.spawn(cmd, argv)
  timer = null
  buffer = []
  proc.on 'close', (code, signal)->
  	console.log('proc closed');
  proc.on 'error', ->
  	console.log('proc error');
  proc.on 'exit', ->
  	console.log('proc exit');
  proc.on 'disconnect', ->
  	console.log('proc disconnect');
  proc.on 'message', ->
  	console.log('proc message');
  proc.stdout.on 'data', (data) ->
    #console.log "Data ----------"
    #console.log (""+data).replace(/\x1b/g, "<ESC>")
    buffer.push data
    if not timer
      timer = setTimeout finalize_msg, 200
  finalize_msg = ->
    send buffer.join("\n")
    timer = null
    buffer = []
  return (response) ->
    proc.stdin.write(response+"\n")
    #proc.stdin.flush()

ansi_to_markdown = (ansi) ->
  lines = []
  currentSym = ''
  currentLine = 0
  saveData = (data) -> lines.push data
  parser = new ansiparser({
    inst_p: (s) ->
      # if /^u_setup/.exec s
      #   return
      # if s == '[MORE]'
      #   return
      saveData s
      console.log("p ",s)
    inst_c: (collected, params, flag) ->
      console.log("csi",collected,"-",params,"-",flag)
      if flag == 'm'
        for param in params
          switch param
            when 0
              saveData currentSym
              currentSym = ''
            when 1
              currentSym = '*'
              saveData currentSym
            when 4
              currentSym = '_'
              saveData currentSym

    inst_o: (s) -> console.log('osc', s)
    inst_x: (flag) ->
      saveData flag
      console.log("Flag: ",flag)
    inst_e: (collected, flag) -> console.log('esc', collected, flag)
    inst_H: (collected, params, flag) -> console.log('dcs-Hook', collected, params, flag)
    inst_P: (dcs) -> console.log('dcs-Put', dcs)
    inst_U: -> console.log('dcs-Unhook')
  })
  parser.parse ansi
  console.log lines
  return lines.join("")



module.exports = (robot) ->
  botname = process.env.HUBOT_SLACK_BOTNAME

  # setInterval (-> robot.messageRoom config.room_name, "Testing"), 5000

  adventure = new_process config.frotz_path, config.frotz_cmd, (data)->
    #ansi_to_markdown data
    #robot.messageRoom config.room_name, ((ansi_to_markdown data).replace(/^/gm, "> "))
    robot.messageRoom config.room_name, ansi_to_markdown data

  robot.hear /^>(.*)/i, (msg) ->
    if msg.message.room != config.room_name
      return
    adventure msg.match[1]
