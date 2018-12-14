import React, { Component } from "react";

import { ActionCable } from "react-actioncable-provider";
import Author from "./Author";
import axios from "axios";
import { sitekey } from "../../config";

export default class Authors extends Component {
  constructor(props) {
    super(props);
    this.state = { authors: this.props.authors };
  };

  static getDerivedStateFromProps(props, state) {
    if (props.authors !== state.authors) {
      return { authors: props.authors };
    }
    return null;
  }

  onReceived = (message) => {
    if (message.response && this.state.authors.some(a => a.id.toString() === message.response.author_id)) {
      this.setState({
        [ message.author_id ]: {
          imported: message.response.author_imported,
          message: message.message
        }
      })
    }
  };

  render() {
    const authors = this.state.authors.length > 0 ? this.state.authors : undefined;
    if (authors) {
      return (
        <div>
          <ActionCable ref='importsChannel' channel={{ channel: 'ImportsChannel', room: '1' }}
                       onReceived={this.onReceived}/>
          {authors.map(a => {
            const authorState = this.state ? this.state[ a.id ] : { imported: false };
            const author = (authorState) ? Object.assign(a, { imported: authorState.imported }) : a;
            return (
              <Author key={a.id} author={author} response={this.state[ a.id ]} user={this.props.user} />
            )
          })}
        </div>
      )
    } else {
      return (
        <div>
          Loading author for '{this.props.letter}'...
        </div>
      )
    }
  }
}
