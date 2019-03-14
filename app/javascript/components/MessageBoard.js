import React, { Component } from "react";
import Button from "react-bootstrap/lib/Button";
import { ActionCable } from "react-actioncable-provider";
import { sitekey } from "../config";
import Collapse from "react-bootstrap/lib/Collapse";

export default class MessageBoard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      messages: this.props.messages || [],
      open: false,
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

  componentDidMount() {
    this.handleResize();
    window.addEventListener('resize', this.handleResize)
  }

  componentDidUpdate() {
    window.removeEventListener('resize', this.handleResize)
  }

  // Handle the alert toggle
  handleAlertDismiss = (e) => {
    this.setState({ open: !(this.state.open) });
  };

  render() {
    return (
      <div id="message-board">
        <ActionCable ref='importsChannel'
                     channel={{ channel: 'ImportsChannel', room: sitekey }}
                     onReceived={this.onReceived}/>
        <Button className="btn btn-sm board-button"
                variant="outline-primary"
                onClick={this.handleAlertDismiss}
                aria-controls="board"
                aria-expanded={open}>
          <i className="fa fa-list"></i>
          &nbsp;Activity
        </Button>
        <Collapse id="board" in={this.state.open} dimension="width" className="board">
          <div className="board-messages"
               ref={(el) => { this.messagesContainer = el; }}>
            Activity since you loaded this site in reverse order.
            <ul>
            {this.state.messages.map((m, idx) => <li key={`msg${idx}`}>{m}<br/></li>)}
            </ul>
          </div>
        </Collapse>
      </div>
    )
  }
}
