(function() {
  App.imports = App.cable.subscriptions.create("ImportsChannel", {
    // Called when the subscription is ready for use on the server
    connected: function() {},
    // Called when the subscription has been terminated by the server
    disconnected: function() {},
  // Called when there's incoming data on the websocket for this channel
    received: function(data) {}
  });


}).call(this);
