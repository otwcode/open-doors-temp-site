import React, { Component } from "react";
import Collapse from "react-bootstrap/lib/Collapse";
import Card from "react-bootstrap/lib/Card";
import axios from "axios";
import Items from "./Items";
import ImportButtons from "./ImportButtons";
import ButtonToolbar from "react-bootstrap/lib/ButtonToolbar";
import Alert from "react-bootstrap/lib/Alert";
import { ActionCable } from "react-actioncable-provider";

class Author extends Component {
  constructor(props) {
    super(props);
    
    this.state = {
      open: false,
      message: "",
      hasError: false,
      isImporting: false,
      isChecking: false,
      isImported: this.props.author.imported,
      data: {}
    };
  }
  
  componentDidMount = () => {
    // Get stories and bookmarks asynchronously
    axios
      .get(`${this.props.root_path}/items/author/${this.props.author.id}`)
      .then((res) => {
        this.setState({ data: res.data });
      })
  };

  componentDidUpdate(prevProps) {
    if (this.props.message !== prevProps.message) {
      this.setState(Object.assign(this.state, { 
        message: this.props.response.message, 
        hasError: this.props.response.has_error,
        isImported: this.props.author.imported }))
    }
  }

  handleAuthorClick = () => {
    this.setState({ open: !this.state.open })
  };

  handleImporting = (e) => {
    this.stopEvents(e);
    this.setState({ isImporting: true }, () => {
      axios
        .post(`${this.props.root_path}/authors/import/${this.props.author.id}`,
          {},
          {
            headers: {
              'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
              'Content-Type': 'application/json',
            }
          })
        .then(res => {
          const response = res.data[0];
          this.setState({
            hasError: response.has_error,
            isImported: response.author_imported,
            message: response.messages[0]
          });
        })
        .catch(err => {
            console.log(err);
            this.setState({
              hasError: true,
              message: err.response.statusText
            })
          }
        )
        .then(() => this.setState({ isImporting: false }));
    });
  };

  stopEvents(e) {
    e.preventDefault();
    e.stopPropagation();
    e.nativeEvent.stopImmediatePropagation(); // stop it toggling the author
  }

  handleChecking = (e) => {
    this.stopEvents(e);
    this.setState({ isChecking: true }, () => {
      axios
        .post(`${this.props.root_path}/authors/check/${this.props.author.id}`,
          {},
          {
            headers: {
              'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
              'Content-Type': 'application/json',
            }
          })
        .then(res => {
          this.setState({
            hasError: false,
            message: res.data.message
          });
        })
        .catch(err => {
            this.setState({
              hasError: true,
              message: err.response.statusText
            })
          }
        )
        .then(() => this.setState({ isChecking: false }));
    });
  };

  handleDNI = (e) => {};

  render() {
    const { open, message, hasError, isImported, isImporting, isChecking } = this.state;
    const key = `author-${this.props.author.id}`;
    const headerClass = isImporting ? "importing" : "";
    const cardClass = isImported ? "imported" : "";
    const msgAlert = message ? <Alert key={`${key}-msg`} variant={hasError ? "danger" : "success"}>{message}</Alert> :
      <span/>;

    return (
      <Card key={key} className={cardClass}>
        <a name={this.props.author.name.replace(' ', '_').toLowerCase()}/>
        <Card.Header onClick={this.handleAuthorClick}
                     aria-controls="example-collapse-text"
                     aria-expanded={open}
                     className={headerClass}
        >
          <ButtonToolbar className="justify-content-between">
            {this.props.author.name}

            <ImportButtons isChecking={isChecking} onChecking={this.handleChecking} onDNI={this.handleDNI}
                           isImporting={isImporting} isImported={isImported} onImporting={this.handleImporting}/>
          </ButtonToolbar>
          {msgAlert}
        </Card.Header>

        <Collapse in={this.state.open}>
          <Card.Body id="example-collapse-text">
            <Items key={`${key}-items`} data={this.state.data}/>
          </Card.Body>
        </Collapse>
      </Card>
    )
  }
}

export default class Authors extends Component {
  constructor(props) {
    super(props);
    this.state = {}
  }

  onReceived = (message) => {
    if (message.response &&
        this.props.authors.some(a => a.id.toString() === message.author_id)) {
      console.log(`Message for author on this page: ${message.author_id}`);
      this.setState({
        [message.author_id]: {
          imported: message.response[0].author_imported,
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
          const authorState = this.state[a.id];
          const author = (authorState) ? Object.assign(a, { imported: authorState.imported }) : a;
          return (
            <Author key={a.id} author={author} root_path={this.props.root_path} response={this.state[a.id]}/>
          )
        })}
      </div>
    )
  }
}
