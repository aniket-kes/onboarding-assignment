const fs = require('fs');
const path = require('path');

const logFilePath = path.join(__dirname, 'sample.log');
let counter = 1;

const appendNumberToFile = () => {
    fs.appendFile(logFilePath, `${counter}\n`, (err) => {
        if (err) throw err;
        console.log(`Appended ${counter}`);
        counter++;
    });
};

const intervalId = setInterval(appendNumberToFile, 10);

process.on('SIGINT', () => {
    clearInterval(intervalId);
    console.log('Script terminated');
    process.exit();
});