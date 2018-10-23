import React, { Component } from "react";
import * as ReactDOM from "react-dom";
import Alert from "react-bootstrap/lib/Alert";
import Button from "react-bootstrap/lib/Button";
import { ActionCable } from "react-actioncable-provider";

export default class MessageBoard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      messages: this.props.messages || [],
      hideAlert: true
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

  // Handle the alert toggle
  handleAlertDismiss = (e) => {
    this.setState({ hideAlert: !(this.state.hideAlert) });
  };

  render() {
    return (
      <div className="message-board">
        <ActionCable ref='importsChannel' channel={{ channel: 'ImportsChannel', room: '1' }}
                     onReceived={this.onReceived}/>
        <Button className="btn-sm" variant="outline-primary" onClick={this.handleAlertDismiss}>Activity stream</Button>
        <Alert key="messages"
               variant={this.props.type} 
               style={{ fontSize: 'x-small', height: '100%', overflowY: 'scroll' }}
               ref={(el) => { this.messagesContainer = el; }}
               hidden={this.state.hideAlert}>
          {this.state.messages.map((m, idx) => <span key={`msg${idx}`}>{m}<br/></span>)}
        </Alert>
      </div>
    )
  }
}
