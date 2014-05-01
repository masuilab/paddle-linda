http = require 'http'
fs   = require 'fs'
url  = require 'url'
ArduinoFirmata = require 'arduino-firmata'

## HTTP Server ##

app_handler = (req, res) ->
  _url = url.parse(decodeURI(req.url), true);
  path = if _url.pathname == '/' then '/index.html' else _url.pathname
  console.log "#{req.method} - #{path}"
  fs.readFile __dirname+path, (err, data) ->
    if err
      res.writeHead 500
      return res.end 'error load file'
    res.writeHead 200
    res.end data

app = http.createServer(app_handler)
io = require('socket.io').listen(app)
io.configure 'development', ->
  io.set 'log level', 2


## Linda Server ##

linda = require('linda-socket.io').Linda.listen(io: io, server: app)
ts = linda.tuplespace('paddle')

process.env.PORT ||= 3000
app.listen process.env.PORT
console.log "server start - port:#{process.env.PORT}"


## Arduino ##

arduino = new ArduinoFirmata()
arduino.on 'connect', ->
  arduino.on 'analogChange', (e) ->
    return if e.pin > 1
    data =
      type: 'paddle'
      direction: if e.pin == 0 then "left" else "right"
      value: e.value
    console.log data
    ts.write data

arduino.connect process.env.ARDUINO

