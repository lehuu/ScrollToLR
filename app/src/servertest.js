import * as net from "net";

const senderSocket = net.connect({ host: "localhost", port: 58701 }, () => {
  // 'connect' listener
  console.log("Sender connected!");
  senderSocket.write("ping\n");
});

senderSocket.on("end", () => {
  console.log("Sender disconnected");
});

console.log("Trying to connect Receiver");

const receiverSocket = new net.Socket();

function makeReceiverConnection() {
  receiverSocket.connect(58702, "localhost");
}
receiverSocket.on("data", (data) => {
  console.log(data.toString());
});
receiverSocket.on("end", () => {
  console.log("Receiver disconnected");
});
receiverSocket.on("error", (err) => {
  console.log(err);
});
receiverSocket.on("close", () => {
  console.log("close");
  setTimeout(makeReceiverConnection, 1000);
});

receiverSocket.on("connect", () => {
  console.log("receiver connected");
});

makeReceiverConnection();
