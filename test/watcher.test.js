const fs = require('fs');
const path = require('path');
const { expect } = require('chai');
const Tailf = require('../watcher');


describe('Tailf', () => {
  const sampleFilePath = path.join(__dirname, 'sample.log');
  const linesToRead = 10;
  let watcher;
  
    beforeEach(() => {
      fs.writeFileSync(sampleFilePath, 'Line 1\nLine 2\nLine 3\nLine 4\nLine 5\nLine 6\nLine 7\nLine 8\nLine 9\nLine 10');
      watcher = new Tailf(sampleFilePath, linesToRead);
    });

    it('should initialize with correct properties', () => {
      expect(watcher.filePath).to.equal(sampleFilePath);
      expect(watcher.lines).to.equal(linesToRead);
      expect(watcher.store_logs).to.be.an('array').that.is.empty;
      expect(watcher.lastPosition).to.equal(0);
      expect(watcher.emitCount).to.equal(0);
    });

    it('should read the last 10 lines from the log file', () => {
      watcher.start();
      expect(watcher.store_logs).to.have.lengthOf(10);
      expect(watcher.store_logs).to.include('Line 1');
      expect(watcher.store_logs).to.include('Line 10');
    });

    it('should read new lines added to the log file', (done) => {
      watcher.start();
      fs.appendFileSync(sampleFilePath, '\nLine 11\nLine 12');
      watcher.readNewLines();
      expect(watcher.store_logs).to.have.lengthOf(10);
      expect(watcher.store_logs).to.include('Line 3');
      expect(watcher.store_logs).to.include('Line 12');
      done();
    });

    it('should emit new lines when the log file is updated', (done) => {
      watcher.start();
      watcher.on('newLines', (newLogs) => {
        expect(newLogs).to.include('Line 11');
        expect(newLogs).to.include('Line 12');
        done();
      });
      fs.appendFileSync(sampleFilePath, '\nLine 11\nLine 12');
      watcher.readNewLines();
    });
  
    afterEach(() => {
      if (fs.existsSync(sampleFilePath)) {
        fs.unlinkSync(sampleFilePath);
      }
    });
});
