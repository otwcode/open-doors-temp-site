import React, { Component } from "react";
import { connect } from "react-redux";
import { fetchAuthorItems, importAuthor, checkAuthor } from "../../actions";

import Collapse from "react-bootstrap/Collapse";
import Card from "react-bootstrap/Card";
import Items from "./Items";
import ImportButtons from "../buttons/ImportButtons";
import ButtonToolbar from "react-bootstrap/ButtonToolbar";
import Alert from "react-bootstrap/Alert";
import { ActionCable } from "react-actioncable-provider";
import { logStateAndProps } from "../../utils/logging";
import { sitekey } from "../../config";

class Author extends Component {
  constructor(props) {
    super(props);

    this.state = {
      open: false,
      hasError: false,
      isImporting: false,
      isChecking: false,
      isImported: this.props.author.imported,
      // Increment this on each change to force children to update
      version: 1
    };
  }

  componentDidUpdate(prevProps) {
    // logStateAndProps("Author componentDidUpdate", this.props.author.name, this);
    if (this.props.data !== prevProps.data) {
      this.setState(Object.assign(this.state, {
        messages: this.props.data.messages,
        hasError: !this.props.data.success,
        isImported: this.props.data.author_imported,
        data: this.props.data,
        version: this.state.version + 1
      }))
    }
  }

  handleAuthorClick = () => {
    this.props.fetchAuthorItems(this.props.author.id);
    this.setState({ open: !this.state.open });
  };

  handleImporting = (e) => {
    this.stopEvents(e);
    this.setState(
      { isChecking: true, hideAlert: true, open: false },
      () => {
        this.props.importAuthor(this.props.author.id)
          .then(() => this.setState({
            open: true,
            hideAlert: false,
            isImporting: false,
            isImported: this.props.data.author_imported,
            hasError: !this.props.data.success
          }))
      }
    );
  };

  stopEvents = (e) => {
    e.preventDefault();
    e.stopPropagation();
  };

  handleChecking = (e) => {
    this.stopEvents(e);
    this.setState(
      { isChecking: true, hideAlert: true, open: false },
      () => {
      this.props.checkAuthor(this.props.author.id)
        .then(() => {
          this.setState({
            hideAlert: false,
            isChecking: false,
            isImported: this.props.data.author_imported,
            hasError: !this.props.data.success
          })
        });
    });
  };

  handleDNI = (e) => {
    alert("Not working - see OD-623")
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
    const msg = messages ? <ul>{messages.map((item, idx) => <li key={idx}>{item}</li>)}</ul> : "";
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

  authorClass = (isImported, author) => {
    if (author) {
    const imported = isImported ? "imported" : "";
    const dni = author.do_not_import ? "do_not_import" : "";
    const errors = author.errors && author.errors.length > 0 ? "error" : "";
    return `author ${imported} ${dni} ${errors}`;
    } else return "author";
  };

  render() {
    // logStateAndProps("Author", this.props.author.name, this);

    // Extract data from the state
    const { open, isImporting, isChecking, isImported } = this.state;
    const author = this.props.author;
    const importData = this.props.data ? this.props.data : {};
    const { items, messages, author_imported } = importData;

    // Some utility variables for simplicity
    const key = `author-${author.id}-${this.state.version}`;
    const headerClass = (isImporting ? " importing" : "") + (isChecking ? " checking" : "");

    return (
      <Card key={key} id={key} className={this.authorClass(isImported, author)}>
        <Card.Header onClick={this.handleAuthorClick}
                     aria-controls={`${key}-collapse`}
                     aria-expanded={open}
                     className={headerClass}>
          <ActionCable ref='importsChannel' channel={{ channel: sitekey, room: 1 }}
                       onReceived={this.handleBroadcast}/>
          <ButtonToolbar className="justify-content-between">
            <Card.Title>{author.name}</Card.Title>
            { this.props.user ?
            <ImportButtons isChecking={isChecking}
                           isImporting={isImporting}
                           isImported={isImported}
                           importText="Import All"
                           onChecking={this.handleChecking}
                           onDNI={this.handleDNI}
                           onImporting={this.handleImporting}
                           showText={true}
            />
              : "" }
            {author.errors.length > 0 && <ul>{author.errors.map((e, i) => <li key={i}>{e}</li>)}</ul>}
          </ButtonToolbar>
          {this.msgAlert(key, messages)}
        </Card.Header>

        <Collapse in={this.state.open}>
          <Card.Body id={`${key}-collapse`}>
            <Items key={`${key}-items`} data={items} user={this.props.user} authorVersion={this.state.version} />
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