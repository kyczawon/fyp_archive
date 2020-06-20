const electron = require('electron');
const {ipcRenderer} = electron;
const ul = document.querySelector('ul');
var app = electron.remote.app;

var dir = app.getAppPath() + '/scripts2'
const fs = require('fs');
var exec = require('child_process').exec

console.log('run')

fs.readdir(dir, (err, files) => {
  files.forEach(file => {
    console.log(file);
    ul.className = 'collection';
    const li = document.createElement('li');
    li.className = 'collection-item';
    const itemText = document.createTextNode(file);

    li.appendChild(itemText);
    ul.appendChild(li);
  });
});

ipcRenderer.on('item:add', function(e, item){
    ul.className = 'collection';
    const li = document.createElement('li');
    li.className = 'collection-item';
    const itemText = document.createTextNode(item);

    li.appendChild(itemText);
    ul.appendChild(li);
});

ul.addEventListener('click', openItem);

document.getElementById("run").addEventListener("click", function(){
  const testFolder = 'C:/Program Files (x86)/YOKOGAWA/WTViewerFreePlus/DATA';

  

  // fs.readdir(testFolder, (err, files) => {
  //   files.sort
  //   const name = 'test'
  //   const input_file = testFolder+'/'+files[0]
  //   const output_file = app.getAppPath()+'/'+name+'.csv'
  //   const plot_file = app.getAppPath()+'/plots/'+name+'.png'

  //   var python = require('child_process').spawn('python', [`python data_processing/trim2.py -i ${input_file} -o ${output_file} -p ${plot_file}`]);
  //   python.stdout.on('data',function(data){
        
  //     })
  //   });

  var python = require('child_process').spawn('python', ['../windows_automation/navigate_viewer.py']);
    python.stdout.on('data',function(data){
      let child = exec("bash ./scripts/test_youtube.sh", {timeout: 30000 }, (err, stdout, stderr) => {
        var python2 = require('child_process').spawn('python', ['../windows_automation/close_viewer.py']);
        python.stdout.on('data',function(data){
            console.log("data: ",data.toString('utf8'));
        });
      })
    });
});

function openItem(e){
    console.log(e.target.innerHTML)
    const item = e.target.innerHTML;
    ipcRenderer.send('item:open', item)
}

function removeItem(e){
    event.target.remove();
    if(ul.children.length == 0){
        ul.className = '';
    }
}