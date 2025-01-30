//Define EvenEmitter

const event = require('events')
const fs = require('fs');
const path = require('path');
const buffer = new Buffer.alloc(1024);


store_logs = []
let lastPosition = 0


class Tailf extends event.EventEmitter {
  constructor(filePath, lines) {
    super();
    this.filePath = filePath;
    this.lines = lines;
  }


  start() {
    const bufferSize = 1024;
    let lineCount = 0;
    let position = 0;
    let fileDescriptor;
  
    try {
      fileDescriptor = fs.openSync(this.filePath, 'r');
      const fileSize = fs.statSync(this.filePath).size;
      position = fileSize;
      console.log("Size of the file is", position)
  
      while (lineCount < this.lines && position > 0) {
        const readSize = Math.min(bufferSize, position);
        console.log('readSize:', readSize);
        position -= readSize;
        console.log("position:", position);
        fs.readSync(fileDescriptor, buffer, 0, readSize, position);
        console.log(buffer.length, "Buffer length")
  
        console.log("outside the for loop readsize", readSize)
        for (let i = readSize - 1; i >= 0; i--) {
          console.log("outside the loop",i)
          if (buffer[i] === '\n'.charCodeAt(0)) {
            console.log("inside the loop",i)
            lineCount++;
            if (lineCount === this.lines) {
              position += i + 1;
              break;
            }
          }
        }
      }
      
      console.log("Position after the loop", position)
      const remainingSize = fileSize - position;
      console.log("Remaining Size", remainingSize)
      const remainingBuffer = Buffer.alloc(remainingSize);
      fs.readSync(fileDescriptor, remainingBuffer, 0, remainingSize, position);
      console.log(remainingBuffer.toString('utf8'));
      
      const logs = remainingBuffer.toString('utf8').split('\n');
      logs.forEach(log => {
        store_logs.push(log)
      })
  
      lastPosition = fileSize;
    } catch (err) {
      console.error('Error reading file:', err);
    } finally {
      if (fileDescriptor !== undefined) {
        fs.closeSync(fileDescriptor);
      }
    }
  }

  readNewLines() {
    const fileSize = fs.statSync(this.filePath).size;
    if (fileSize > lastPosition) {
      const newSize = fileSize - lastPosition;
      const buffer = Buffer.alloc(newSize);
      const fileDescriptor = fs.openSync(this.filePath, 'r');
      fs.readSync(fileDescriptor, buffer, 0, newSize, lastPosition);
      const newLogs = buffer.toString('utf8').split('\n').filter(log => log.trim());

      newLogs.forEach(log => {
        store_logs.push(log);
        if (store_logs.length > this.lines) {
          store_logs.shift(); // Maintain only the last `lines` number of entries
        }
      });

      lastPosition = fileSize;
      fs.closeSync(fileDescriptor);
      this.emit('newLines', newLogs);
    }
  }
  
}

module.exports = Tailf;