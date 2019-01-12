import React, { Component } from "react";

import Card from "react-bootstrap/lib/Card";
import Collapse from "react-bootstrap/lib/Collapse";
import Tooltip from "react-bootstrap/lib/Tooltip";
import OverlayTrigger from "react-bootstrap/lib/OverlayTrigger";
import Alert from "react-bootstrap/lib/Alert";
import ButtonToolbar from "react-bootstrap/lib/ButtonToolbar";
import Button from "react-bootstrap/lib/Button";

import { sitekey } from "../../config";

class Item extends Component {
  constructor(props) {
    super(props);
    this.state = {
      open: this.props.open,
      hideAlert: false
    };
  }

  stopEvents = (e) => {
    e.preventDefault();
    e.stopPropagation();
  };

  handleItemClick = () => {
    this.setState({ open: !this.state.open })
  };

  handleAlertDismiss = (e) => {
    this.stopEvents(e);
    this.setState({ hideAlert: true });
  };

  msgAlert = (key, messages, success, errors) => {
    console.log(key);
    console.log(errors);
    const hasError = !success || errors.length > 0;
    // TODO fix this when AO3-5572 is done
    let msg = errors;
    if (typeof (messages) === "string") {
      msg.append(messages);
    } else if (messages) {
      msg.concat(messages);
    }
    return msg.length > 0 ?
      <Alert key={`${key}-msg`} variant={hasError ? "danger" : "success"} className="alert-dismissible"
             hidden={this.state.hideAlert}>
        {<ul>{msg.map((item, idx) => <li key={idx}>{item}</li>)}</ul>}
        <button type="button" className="close" data-dismiss="alert" aria-label="Close"
                onClick={this.handleAlertDismiss}>
          <span aria-hidden="true">&times;</span>
        </button>
      </Alert> :
      <span/>;
  };

  itemClass = (item) => {
    if (item) {
      const imported = item.imported ? "imported" : "";
      const dni = item.do_not_import ? "do_not_import" : "";
      const errors = item.errors && item.errors.length > 0 ? "error" : "";
      return `item ${imported} ${dni} ${errors}`;
    } else return "item";
  };

  render() {
    const { item, isStory, isImporting } = this.props;
    const key = isStory ? `story-${item.id}` : `link-${item.id}`;
    const headerClass = isImporting ? "importing" : "";
    const { messages, success, ao3_url } = this.props.importResult ? this.props.importResult : {};
    const archive_url = ao3_url || item.ao3_url;
    return (
      <Card id={key} key={key} className={this.itemClass(item)}>
        <Card.Header onClick={this.handleItemClick}
                     aria-controls="blurb"
                     aria-expanded={open}
                     className={headerClass}>
          <ButtonToolbar className="justify-content-between">
            <OverlayTrigger
              placement="bottom"
              overlay={
                <Tooltip id="tooltip">id: {item.id}</Tooltip>
              }>
              <Card.Subtitle className="itemTitle">
                {this.props.item.title}
              </Card.Subtitle>
            </OverlayTrigger>
            {isStory ? '' :
              <Button variant="outline-primary" size="sm" href={item.url}
                      className="button-import" title="visit link" target="_blank">
                <i className="fa fa-external-link"/> Visit link</Button>}
            {archive_url ?
              <Button variant="outline-info" size="sm" className="import-button" href={archive_url}
                      target="_blank">AO3</Button>
              : ""}
          </ButtonToolbar>
          {this.msgAlert(key, messages, success, item.errors)}
        </Card.Header>
        <Collapse in={this.state.open}>
          <Card.Body>
            <b>Rating:</b> {item.rating || "None"}<br/>
            <b>Warnings:</b> {item.warnings || "None"}<br/>
            <b>Categories:</b> {item.categories || "None"}<br/>
            <b>Fandoms:</b> {item.fandoms || "None"}<br/>
            <b>Relationships:</b> {item.relationships || "None"}<br/>
            <b>Characters:</b> {item.characters || "None"}<br/>
            <b>Tags:</b> {item.tags || "None"}<br/>
            <b>Date:</b> {item.date || "No date"}
            {isStory &&
            <span> - <b>Updated:</b> {item.updated || "No update date set"}</span>
            }
            <br/>

            <b>Summary: </b><span dangerouslySetInnerHTML={{ __html: item.summary }}/>
            {item.summaryTooLong ?
              <span className="badge badge-danger">{item.summaryLength}</span> : ""}<br/>

            {(isStory) ?
              <ol>
                {
                  item.chapters.map((chapter) => {
                    return (
                      <li key={`chapter-${chapter.id}`}><a
                        href={`/${sitekey}/chapters/${chapter.id}`}>{chapter.title}</a>
                        {chapter.textTooLong ?
                          <span className="badge badge-danger">{chapter.textLength}</span> : ""}
                      </li>)
                  })
                }
              </ol> : ''
            }
          </Card.Body>
        </Collapse>
      </Card>
    )
  }
}

export default class Items extends Component {
  render() {
    if (this.props.data) {
      if (this.props.data.error) {
        return (
          <Alert variant="warning">
            <h4>{this.props.data.status}</h4>
            {this.props.data.error.map((m, i) => <span key={i}>{m}<br/></span>)}
          </Alert>
        )
      } else {
        const stories = this.props.data.stories;
        const links = this.props.data.story_links;
        return (
          <div className="items">
            {
              stories && stories.length ?
                <div>
                  <Card.Title>Stories</Card.Title>
                  {stories.map((s) => {
                    console.log(s);
                    console.log(this.props);
                    const importResult = this.props.works ? this.props.works[ s.id ] : undefined;
                    return <Item key={`story-${s.id}`} item={s} isStory={true} importResult={importResult}/>
                  })}
                </div> : ''
            }
            {
              links && links.length ?
                <div>
                  <Card.Title>Story Links</Card.Title>
                  {links.map((s) => {
                    const importResult = this.props.bookmarks ? this.props.bookmarks[ s.id ] : undefined;
                    return <Item key={`link-${s.id}`} item={s} isStory={false} importResult={importResult}/>
                  })}
                </div> : ''
            }
          </div>
        )
      }
    } else {
      return (
        <Alert variant="warning">
          <h4>No data</h4>
          No data could be retrieved for this author.
        </Alert>
      )
    }
  }
}
