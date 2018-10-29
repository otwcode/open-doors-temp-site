import React, { Component } from "react";
import { connect } from "react-redux";
import { fetchAuthorItems, importAuthor } from "../../actions";

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
      data: {
        import: { author_imported: this.props.author.imported },
        items: {}
      }
    };
  }

  componentDidUpdate(prevProps) {
    if (this.props.message !== prevProps.message) {
      this.setState(Object.assign(this.state, {
        message: this.props.response.message,
        hasError: this.props.response.has_error,
        isImported: this.props.author.imported
      }))
    }
    if (this.props.data !== prevProps.data) {
      this.setState(Object.assign(this.state, { data: this.props.data }));
    }
  }

  handleAuthorClick = () => {
    this.setState({ open: !this.state.open });
    // Get stories and bookmarks asynchronously
    this.props.fetchAuthorItems(this.props.root_path, this.props.author.id);
  };

  handleImporting = (e) => {
    this.stopEvents(e);
    this.setState(
      { isImporting: true },
      () => {
        this.props.importAuthor(this.props.root_path, this.props.author.id)
          .then(() => this.setState({
            isImporting: false,
            hasError: (this.props.data.error === undefined)
          }))
      }
    );
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
              message: err.statusText
            })
          }
        )
        .then(() => this.setState({ isChecking: false }));
    });
  };

  handleDNI = (e) => {
  };

  handleAlertDismiss = (e) => {
    this.stopEvents(e);
    this.setState({ hideAlert: true });
  };

  handleBroadcast = (broadcast) => {
    if (broadcast.author_id === this.props.author.id.toString()) {
      this.setState({ isImporting: broadcast.isImporting })
    }
  };

  msgAlert = (key, messages) => {
    const { hasError } = this.state;
    const msg = messages ? <ul>{messages.map((item, idx) => <li key={idx}>{item}</li>)}</ul> : this.state.message;
    return msg ?
      <Alert key={`${key}-msg`} variant={hasError ? "danger" : "success"} className="alert-dismissible" hidden={this.state.hideAlert}>
        {msg}
        <button type="button" className="close" data-dismiss="alert" aria-label="Close" onClick={this.handleAlertDismiss}>
          <span aria-hidden="true">&times;</span>
        </button>
      </Alert> :
      <span/>;
  };

  render() {
    // Extract data from the state
    const { open, isImporting, isChecking } = this.state;
    const items = this.state.data && this.state.data.items ? this.state.data.items : {};
    const importData = this.state.data && this.state.data.import ? this.state.data.import : {};

    // {messages: Array(1), status: "error", success: false, author_imported: false, author_id: 48}
    const { messages, author_imported: isImported } = importData;

    // Some utility variables for simplicity
    const key = `author-${this.props.author.id}`;
    const headerClass = isImporting ? "importing" : "";
    const cardClass = isImported ? "imported" : "";

    return (
      <Card key={key} className={cardClass}>
        <a name={this.props.author.name.replace(' ', '_').toLowerCase()}/>
        <Card.Header onClick={this.handleAuthorClick}
                     aria-controls="example-collapse-text"
                     aria-expanded={open}
                     className={headerClass}>
          <ActionCable ref='importsChannel' channel={{ channel: 'ImportsChannel', room: '1' }}
                       onReceived={this.handleBroadcast}/>
          <ButtonToolbar className="justify-content-between">
            {this.props.author.name}
            <ImportButtons isChecking={isChecking} onChecking={this.handleChecking} onDNI={this.handleDNI}
                           isImporting={isImporting} isImported={isImported} onImporting={this.handleImporting}/>
          </ButtonToolbar>
          {this.msgAlert(key, messages)}
        </Card.Header>

        <Collapse in={this.state.open}>
          <Card.Body id="example-collapse-text">
            <Items key={`${key}-items`} data={items}/>
          </Card.Body>
        </Collapse>
      </Card>
    )
  }
}

function mapStateToProps({ authorItems }, ownProps) {
  return { data: authorItems[ ownProps.author.id ] };
}

export default connect(mapStateToProps, { fetchAuthorItems, importAuthor })(Author);