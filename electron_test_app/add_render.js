// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// No Node.js APIs are available in this process because
// `nodeIntegration` is turned off. Use `preload.js` to
// selectively enable features needed in the rendering
// process.
const electron = require('electron');
fs = require('fs');
const { ipcRenderer } = electron;
var app = electron.remote.app;
// document.querySelector('form').addEventListener('submit', submitForm);

var exec = require('child_process').exec
function Callback(err, stdout, stderr) {
    console.log('end');
    if (err) {
        console.log(`exec error: ${err}`);
        return;
    } else {
        console.log(`${stdout}`);
    }
}

document.getElementById('run').addEventListener("click", function () {
    const item = document.querySelector('#item').value;
    var dir = app.getAppPath() + '/scripts'
    let child = exec("sh " + dir + "/" + item + '.sh', (err, stdout, stderr) => {
        console.log('executed');
    })
});


document.getElementById('submit').addEventListener("click", function () {
    const item = document.querySelector('#item').value;


    let child = exec("bash test.sh", { shell: '/bin/bash', timeout: 2000 }, (err, stdout, stderr) => {
        console.log(stdout)

        var words = stdout.split("\n");
        console.log(words);

        code = "sleep 2\n" + "adb shell input tap $((16#" + words[0].slice(0, -1) + ")) $((16#" + words[1].slice(0, -1) + "))"

        var dir = app.getAppPath() + '/scripts'

        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir);
        }

        fs.writeFile(dir + '/' + item + '.sh', code, (err) => {
            if (err) throw err;
            console.log('The file has been saved!');
            fs.chmodSync(dir + '/' + item + '.sh', 0o755);
        });

        console.log(dir + '/' + item + '.sh');
    })
});
// function submitForm(e){
//     e.preventDefault();
// }