import React, { Component } from "react";
import Alert from "react-bootstrap/lib/Alert";
import { ActionCable } from "react-actioncable-provider";
import * as ReactDOM from "react-dom";

export default class MessageBoard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      messages: this.props.messages || []
    };
  }

  onReceived = (message) => {
    this.setState({
      messages: [
        ...this.state.messages,
        message.message
      ]
    })
  };

  // Not in use just yet
  sendMessage = (e) => {
    e.preventDefault();
    const message = this.state.text;
    this.setState({ text: "" });
    // Call perform or send
    this.refs.importsChannel.perform('send_message', { message })
  };

  // These three make the view scroll
  scrollToBottom = () => {
    const messagesContainer = ReactDOM.findDOMNode(this.messagesContainer);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  };

  componentDidMount() {
    this.scrollToBottom();
  }

  componentDidUpdate() {
    this.scrollToBottom();
  }

  render() {
    return (
      <div style={{ height: '100%' }}>
        <ActionCable ref='importsChannel' channel={{ channel: 'ImportsChannel', room: '1' }}
                     onReceived={this.onReceived}/>
        <Alert key="messages" 
               variant={this.props.type} 
               style={{ fontSize: 'x-small', height: '100%', overflowY: 'scroll' }}
               ref={(el) => { this.messagesContainer = el; }}>
          {this.state.messages.map((m, idx) => <span key={`msg${idx}`}>{m}<br/></span>)}
        </Alert>
      </div>
    )
  }
}
