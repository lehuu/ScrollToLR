const net = require("net");

const senderSocket = new net.Socket();

const makeSenderConnection = () => {
  console.log("Trying to connect Sender");
  senderSocket.connect(58701, "localhost");
};
senderSocket.on("data", (data) => {
  console.log(data.toString());
});
senderSocket.on("end", () => {
  console.log("Receiver disconnected");
});
senderSocket.on("error", (err) => {
  console.log(err);
});
senderSocket.on("close", () => {
  console.log("close");
  setTimeout(makeSenderConnection, 1000);
});

senderSocket.on("connect", () => {
  console.log("sender connected");
});

const receiverSocket = new net.Socket();

const makeReceiverConnection = () => {
  console.log("Trying to connect Receiver");
  receiverSocket.connect(58702, "localhost");
};
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
  senderSocket.write("ping\n");
  senderSocket.write("Exposure|100\n");
});

makeSenderConnection();
makeReceiverConnection();
