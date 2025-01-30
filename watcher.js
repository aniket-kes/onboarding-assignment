const event = require('events')
const fs = require('fs');
const path = require('path');
const buffer = new Buffer.alloc(1024);


class Tailf extends event.EventEmitter {
  constructor(filePath, lines) {
    super();
    this.filePath = filePath;
    this.lines = lines;
    this.store_logs = []
    this.lastPosition = 0
    this.emitCount = 0
  }

  readNewLines() {
    try {
      const fileSize = fs.statSync(this.filePath).size;
      if (fileSize > this.lastPosition) {
      const newSize = fileSize - this.lastPosition;
      const buffer = Buffer.alloc(newSize);
      const fileDescriptor = fs.openSync(this.filePath, 'r');
      fs.readSync(fileDescriptor, buffer, 0, newSize, this.lastPosition);
      const newLogs = buffer.toString('utf8').split('\n').filter(log => log.trim());

      newLogs.forEach(log => {
        this.store_logs.push(log);
        if (this.store_logs.length > this.lines) {
        this.store_logs.shift();
        }
      });

      this.lastPosition = fileSize;
      fs.closeSync(fileDescriptor);
      this.emit('newLines', newLogs);
      }
    } catch (err) {
      if (err.code === 'ENOENT') {
      console.error('File has been deleted');
      } else {
      console.error('Error reading new lines:', err);
      }
    }
  }

  start() {
    var watcher = this;
    const bufferSize = 1024;
    let lineCount = 0;
    let position = 0;
    let fileDescriptor;
  
    try {
      fileDescriptor = fs.openSync(this.filePath, 'r');
      const fileSize = fs.statSync(this.filePath).size;
      position = fileSize;
  
      while (lineCount < this.lines && position > 0) {
        const readSize = Math.min(bufferSize, position);
        position -= readSize;
        fs.readSync(fileDescriptor, buffer, 0, readSize, position);

        for (let i = readSize-2; i >= 0; i--) {
          if (buffer[i] === '\n'.charCodeAt(0)) {
            lineCount++;
            if (lineCount === this.lines) {
              position += i + 1;
              break;
            }
          }
        }
      }
      
      const remainingSize = fileSize - position; //Reading from the 1st line of last 10 lines
      const remainingBuffer = Buffer.alloc(remainingSize);
      fs.readSync(fileDescriptor, remainingBuffer, 0, remainingSize, position);
      
      const logs = remainingBuffer.toString('utf8').split('\n');
      logs.forEach(log => {
        this.store_logs.push(log)
      })
  
      this.lastPosition = fileSize;
    } catch (err) {
      console.error('Error reading file:', err);
    } finally {
      if (fileDescriptor !== undefined) {
        fs.closeSync(fileDescriptor);
      }
    }

    fs.watchFile(this.filePath, {"interval":1000}, () => {
      watcher.readNewLines();
    });

    return this.store_logs;
  }    
}

module.exports = Tailf;
