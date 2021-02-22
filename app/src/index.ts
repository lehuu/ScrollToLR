import { app, BrowserWindow } from "electron";
import * as path from "path";
import * as net from "net";
import * as url from "url";

// Handle creating/removing shortcuts on Windows when installing/uninstalling.
if (require("electron-squirrel-startup")) {
  // eslint-disable-line global-require
  app.quit();
}

const createWindow = (): void => {
  // Create the browser window.
  const mainWindow = new BrowserWindow({
    height: 600,
    width: 800,
  });
  let senderSocket: net.Socket;
  let receiverSocket: net.Socket;

  // and load the index.html of the app.
  mainWindow.loadFile(path.join(__dirname, "../src/index.html"));

  // Open the DevTools.
  mainWindow.webContents.openDevTools();

  /* Instance socket on create window */
  console.log("Trying to connect Sender");
  senderSocket = net.connect({ host: "localhost", port: 58701 }, () => {
    // 'connect' listener
    console.log("Sender connected!");
    senderSocket.write("ping\n");
  });

  senderSocket.on("end", () => {
    console.log("Sender disconnected");
  });

  console.log("Trying to connect Receiver");
  receiverSocket = net.connect({ host: "localhost", port: 58702 }, () => {
    // 'connect' listener
    console.log("Receiver connected!");
    senderSocket.write("ping\n");
  });
  receiverSocket.on("data", (data) => {
    console.log(data.toString());
  });
  receiverSocket.on("end", () => {
    console.log("Receiver disconnected");
  });
};

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on("ready", createWindow);

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    app.quit();
  }
});

app.on("activate", () => {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and import them here.
