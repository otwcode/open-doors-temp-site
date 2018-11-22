import React, { Component } from "react";
import { connect } from "react-redux";
import { fetchAuthorItems, importAuthor, checkAuthor } from "../../actions";

import Collapse from "react-bootstrap/lib/Collapse";
import Card from "react-bootstrap/lib/Card";
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
    if (!this.state.data.items || Object.keys(this.state.data.items).length === 0) {
      this.props.fetchAuthorItems(this.props.author.id);
    }
  };

  handleImporting = (e) => {
    this.stopEvents(e);
    this.setState(
      { isImporting: true, message: "" },
      () => {
        this.props.importAuthor(this.props.author.id)
          .then(() => this.setState({
            hideAlert: false,
            isImporting: false,
            hasError: (this.props.data.error !== undefined)
          }))
      }
    );
  };

  stopEvents(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  handleChecking = (e) => {
    this.stopEvents(e);
    this.setState(
      { isChecking: true, message: "" },
      () => {
      this.props.checkAuthor(this.props.author.id)
        .then(() => this.setState({
          hideAlert: false,
          isChecking: false,
          hasError: (this.props.data.error !== undefined)
        }));
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
      this.setState({ isImporting: broadcast.isImporting, isChecking: broadcast.isChecking })
    }
  };

  msgAlert = (key, messages) => {
    const { hasError } = this.state;
    const msg = messages ? <ul>{messages.map((item, idx) => <li key={idx}>{item}</li>)}</ul> : this.state.message;
    return msg ?
      <Alert key={`${key}-msg`} variant={hasError ? "danger" : "success"} className="alert-dismissible"
             hidden={this.state.hideAlert}>
        {msg}
        <button type="button" className="close" data-dismiss="alert" aria-label="Close"
                onClick={this.handleAlertDismiss}>
          <span aria-hidden="true">&times;</span>
        </button>
      </Alert> :
      <span/>;
  };

  render() {
    // Extract data from the state
    const { open, isImporting, isChecking } = this.state;
    const author = this.props.author;
    const items = this.state.data && this.state.data.items ? this.state.data.items : {};
    const importData = this.state.data && this.state.data.import ? this.state.data.import : {};

    const { messages, author_imported, works, bookmarks } = importData;
    console.log(author_imported);
    const isImported = author_imported || author.imported;

    // Some utility variables for simplicity
    const key = `author-${author.id}`;
    const headerClass = (isImporting ? " importing" : "") + (isChecking ? " checking" : "");
    const cardClass = `author ${isImported ? "imported" : ""} ${author.do_not_import ? "do_not_import" : ""}`;

    return (
      <Card key={key} id={key} className={cardClass}>
        <a name={this.props.author.name.replace(' ', '_').toLowerCase()}/>
        <Card.Header onClick={this.handleAuthorClick}
                     aria-controls="example-collapse-text"
                     aria-expanded={open}
                     className={headerClass}>
          <ActionCable ref='importsChannel' channel={{ channel: 'ImportsChannel', room: '1' }}
                       onReceived={this.handleBroadcast}/>
          <ButtonToolbar className="justify-content-between">
            <Card.Title>{this.props.author.name}</Card.Title>
            <ImportButtons isChecking={isChecking} onChecking={this.handleChecking} onDNI={this.handleDNI}
                           isImporting={isImporting} isImported={isImported} onImporting={this.handleImporting}/>
          </ButtonToolbar>
          {this.msgAlert(key, messages)}
        </Card.Header>

        <Collapse in={this.state.open}>
          <Card.Body id="example-collapse-text">
            <Items key={`${key}-items`} data={items} works={works} bookmarks={bookmarks}/>
          </Card.Body>
        </Collapse>
      </Card>
    )
  }
}

function mapStateToProps({ authorItems }, ownProps) {
  return { data: authorItems[ ownProps.author.id ] };
}

export default connect(mapStateToProps, { fetchAuthorItems, importAuthor, checkAuthor })(Author);