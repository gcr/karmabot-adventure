# Description:
#   Karmabot scripts
#
# Notes:
#   Scripting documentation for hubot can be found here:
#   https://github.com/github/hubot/blob/master/docs/scripting.md

child_process = require 'child_process'
ansiparser = require 'node-ansiparser'

config = {
  room_name: 'if-abcd12341234'
  frotz_path: "/usr/local/bin/frotz"
  frotz_cmd: ["-w", "999", "-h", "999", "-d", "/Users/michael/Downloads/Heliopause.zblorb"]
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
  data = []
  currentSym = ''
  parser = new ansiparser({
    inst_p: (s) ->
      data.push s
      console.log("p ",s)
    #inst_o: (s) -> console.log('osc', s)
    inst_x: (flag) ->
      if flag == '\r'
        data.push currentSym
        currentSym = ''
        data.push '\n'
      console.log("Flag: ",flag)
    inst_c: (collected, params, flag) ->
      console.log("csi",collected,"-",params,"-",flag)
      if flag == 'm'
        for param in params
          switch param
            when 0
              data.push currentSym
              currentSym = ''
            when 1
              currentSym = '*'
              data.push currentSym
            when 4
              currentSym = '_'
              data.push currentSym


    #inst_e: (collected, flag) -> console.log('esc', collected, flag)
    #inst_H: (collected, params, flag) -> console.log('dcs-Hook', collected, params, flag)
    #inst_P: (dcs) -> console.log('dcs-Put', dcs)
    #inst_U: -> console.log('dcs-Unhook')
  })
  parser.parse ansi
  console.log data
  return data.join("")



module.exports = (robot) ->
  botname = process.env.HUBOT_SLACK_BOTNAME

  # setInterval (-> robot.messageRoom config.room_name, "Testing"), 5000

  adventure = new_process config.frotz_path, config.frotz_cmd, (data)->
    #ansi_to_markdown data
    robot.messageRoom config.room_name, ansi_to_markdown data

  robot.hear /^>(.*)/i, (msg) ->
    if msg.message.room != config.room_name
      return
    adventure msg.match[1]

  #robot.hear ///@([a-z0-9_\-\.]+)\-{2,}///i, (msg) ->
  #  user = msg.match[1].replace(/\-+$/g, '')
  #  if msg.message.user.name == user
  #    response_msg = "@" + user
  #    response_msg += ", you are a silly goose and downvoted yourself!"
  #    msg.send response_msg
  #  count = (robot.brain.get(user) or 0) - 1
  #  robot.brain.set user, count
  #  msg.send "@#{user}-- [ouch! now at #{count}]"

  #robot.hear ///#{botname}\s+(leader|shame)board\s*([0-9]+|all)?///i, (msg) ->
  #  users = robot.brain.data._private
  #  tuples = []
  #  for username, score of users
  #    tuples.push([username, score])

  #  if tuples.length == 0
  #    msg.send "The lack of karma is too damn high!"
  #    return

  #  tuples.sort (a, b) ->
  #    if a[1] > b[1]
  #      return -1
  #    else if a[1] < b[1]
  #      return 1
  #    else
  #      return 0
  #
  #  if msg.match[1] == "shame"
  #    tuples = (item for item in tuples when item[1] < 0)
  #    tuples.reverse()
  #  requested_count = msg.match[2]
  #  leaderboard_maxlen = if not requested_count? then 10\
  #    else if requested_count == "all" then tuples.length\
  #    else +requested_count
  #  str = ''
  #  add_spaces = (m) -> m + "\u200A"
  #  for i in [0...Math.min(leaderboard_maxlen, tuples.length)]
  #    username = tuples[i][0]
  #    points = tuples[i][1]
  #    point_label = if points == 1 then "point" else "points"
  #    leader = if i == 0 then " (All hail supreme leader!)" else ""
  #    newline = if i < Math.min(leaderboard_maxlen, tuples.length) - 1 then '\n' else ''
  #    formatted_name = username.replace(/\S/g, add_spaces).trim()
  #    str += "##{i+1}\t[#{points} " + point_label + "] #{formatted_name}" + leader + newline
  #  msg.send(str)

  #robot.hear ///#{botname}\s+karma\s+of\s+@([a-z0-9_\-\.]+)///i, (msg) ->
  #      user = msg.match[1].replace(/\-+$/g, '')
  #      count = robot.brain.get(user) or 0
  #      msg.send "@#{user} has #{count} karma!"
