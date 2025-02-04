const express = require('express');
const { createServer } = require('node:http');
const { join } = require('node:path');
const { Server } = require('socket.io');


const app = express();
const server = createServer(app);
const io = new Server(server);

const fs = require('fs');
const path = require('path');

sample = 'sample.log'
let linesToread = 10
store_logs = []

const Tailf = require('./watcher');
const watcher = new Tailf(sample, linesToread);


function begin() {
  const filePath = path.join(__dirname, 'sample.log');
  store_logs = watcher.start();  
}

begin();

app.get('/', (req, res) => {
    res.send('Hello World')
});

app.get('/log', (req, res) => {
  const filePath = path.join(__dirname, 'index.html');

  res.sendFile(filePath)  
})

io.on('connection', function(socket){

  console.log("connection established");

  watcher.on("newLines", function process(data) {
    socket.emit("updated-log",data);
  });
  
  store_logs = watcher.getLogs();
  socket.emit("log",store_logs);
});

server.listen(3000, () => {
    console.log('Server is running on port 3000')
})

