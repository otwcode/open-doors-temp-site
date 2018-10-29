import React, { Component } from "react";

import { ActionCable } from "react-actioncable-provider";
import Author from "./Author";

export default class Authors extends Component {
  constructor(props) {
    super(props);
    this.state = {}
  }

  onReceived = (message) => {
    if (message.response &&
        this.props.authors.some(a => a.id.toString() === message.response.author_id)) {
      this.setState({
        [ message.author_id ]: {
          imported: message.response.author_imported,
          message: message.message
        }
      })
    }
  };

  render() {
    return (
        <div>
          <ActionCable ref='importsChannel' channel={{ channel: 'ImportsChannel', room: '1' }}
                       onReceived={this.onReceived}/>
          {this.props.authors.map(a => {
            const authorState = this.state[ a.id ];
            const author = (authorState) ? Object.assign(a, { imported: authorState.imported }) : a;
            return (
                <Author key={a.id} author={author} root_path={this.props.root_path} response={this.state[ a.id ]}/>
            )
          })}
        </div>
    )
  }
}
