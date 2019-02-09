import React, { Component } from "react";
import * as ReactDOM from "react-dom";
import Alert from "react-bootstrap/lib/Alert";
import Button from "react-bootstrap/lib/Button";
import { ActionCable } from "react-actioncable-provider";
import { sitekey } from "../config";

export default class MessageBoard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      messages: this.props.messages || [],
      hideAlert: true,
      boardHeight: window.innerHeight - 35
    };
  }

  handleResize = () => this.setState({
    boardHeight: window.innerHeight - 35
  });

  onReceived = (message) => {
    this.setState({
      messages: [
        message.message,
        ...this.state.messages
      ]
    })
  };

  // These three make the view scroll
  // scrollToBottom = () => {
  //   const messagesContainer = ReactDOM.findDOMNode(this.messagesContainer);
  //   messagesContainer.scrollTop = messagesContainer.scrollHeight;
  // };

  componentDidMount() {
    // this.scrollToBottom();
    this.handleResize();
    window.addEventListener('resize', this.handleResize)
  }

  componentDidUpdate() {
    // this.scrollToBottom();
    window.removeEventListener('resize', this.handleResize)
  }

  // Handle the alert toggle
  handleAlertDismiss = (e) => {
    this.setState({ hideAlert: !(this.state.hideAlert) });
  };

  render() {
    return (
      <div className="message-board">
        <ActionCable ref='importsChannel'
                     channel={{ channel: 'ImportsChannel', room: sitekey }}
                     onReceived={this.onReceived}/>
        <Button className="btn-sm" variant="outline-primary" onClick={this.handleAlertDismiss}>Activity stream</Button>
        <Alert key="messages"
               variant={this.props.type} 
               style={{ fontSize: 'x-small', maxHeight: this.state.boardHeight, overflowY: 'scroll', }}
               ref={(el) => { this.messagesContainer = el; }}
               hidden={this.state.hideAlert}>
          {this.state.messages.map((m, idx) => <span key={`msg${idx}`}>{m}<br/></span>)}
        </Alert>
      </div>
    )
  }
}
