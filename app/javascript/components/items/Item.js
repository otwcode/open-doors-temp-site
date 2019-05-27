import React, { Component } from "react";
import { connect } from "react-redux";
import { importItem } from "../../actions";

import Card from "react-bootstrap/lib/Card";
import ButtonToolbar from "react-bootstrap/lib/ButtonToolbar";
import OverlayTrigger from "react-bootstrap/lib/OverlayTrigger";
import Tooltip from "react-bootstrap/lib/Tooltip";
import ImportButtons from "../buttons/ImportButtons";
import Button from "react-bootstrap/lib/Button";
import Collapse from "react-bootstrap/lib/Collapse";
import { sitekey } from "../../config";
import { MessageAlert } from "./MessageAlert";

class Item extends Component {
  constructor(props) {
    super(props);
    this.state = {
      open: this.props.open,
      hideAlert: false,
      isImporting: false
    };
  }

  stopEvents = (e) => {
    e.preventDefault();
    e.stopPropagation();
  };

  handleItemClick = () => {
    this.setState({ open: !this.state.open })
  };

  handleImporting = (e) => {
    alert("importing");
    this.stopEvents(e);
    const type = this.props.isStory ? `story` : `link`;
    this.setState(
      { isImporting: true, message: "" },
      () => {
        this.props.importItem(this.props.item.id, type)
          .then(() => this.setState({
            hideAlert: false,
            isImporting: false,
            isImported: this.props.item.imported,
            hasError: !this.props.item.success
          }))
      }
    );
  };

  handleChecking = (e) => {
    this.stopEvents(e);
    alert("checking")
  };

  handleDNI = (e) => {
    this.stopEvents(e);
    alert("dni")
  };

  handleAlertDismiss = (e) => {
    this.stopEvents(e);
    this.setState({ hideAlert: true });
  };

  msgAlert = (key, messages, success) => {
    const hasError = !success;
    let msg = messages;
    return msg && msg.length > 0 ?
      <MessageAlert key={`${key}-msg`}
                    hasError={hasError}
                    hidden={this.state.hideAlert}
                    msg={msg}
                    onClick={this.handleAlertDismiss}/> :
      <span/>;
  };

  itemClass = (item) => {
    if (item) {
      const imported = item.imported ? "imported" : "";
      const dni = item.do_not_import ? "do_not_import" : "";
      const errors = _.isEmpty(item.errors) ? "" : "error";
      return `item ${imported} ${dni} ${errors}`;
    } else return "item";
  };

  render() {
    const { isImporting } = this.state;
    const { item, isStory, isChecking } = this.props;
    // logStateAndProps("Item", item.name, this);
    const key = isStory ? `story-${item.id}` : `link-${item.id}`;
    const headerClass = isImporting ? " importing" : "";
    const { messages, success, ao3_url, imported } = item;
    return (
      <Card id={key} key={key} className={this.itemClass(item)}>
        <Card.Header onClick={this.handleItemClick}
                     aria-controls="blurb"
                     aria-expanded={open}
                     className={headerClass}>
          <ButtonToolbar className="justify-content-between">
            <OverlayTrigger
              placement="bottom"
              overlay={<Tooltip id="tooltip">id: {item.id}</Tooltip>}>
              <Card.Subtitle className="itemTitle">
                {item.title}
              </Card.Subtitle>
            </OverlayTrigger>
            {this.props.user ?
              <ImportButtons isChecking={isChecking}
                             isImporting={isImporting}
                             isImported={imported}
                             importText="Import"
                             onChecking={this.handleChecking}
                             onDNI={this.handleDNI}
                             onImporting={this.handleImporting}>
                {isStory ? "" :
                  <Button variant="outline-primary" size="sm" href={item.url}
                          className="button-import" title="visit link" target="_blank">
                    <i className="fa fa-external-link"/> Visit link</Button>}
                {ao3_url ?
                  <Button variant="outline-info" size="sm" className="import-button" href={ao3_url}
                          target="_blank">AO3</Button>
                  : ""}
              </ImportButtons>
              : ""}

          </ButtonToolbar>
          {this.msgAlert(key, messages, success)}
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
            <b>Language code:</b> {item.language_code || "MISSING"}<br/>
            <b>Date:</b> {item.date || "No date"}
            {isStory &&
            <span> - <b>Updated:</b> {item.updated || "No update date set"}</span>
            }
            <br/>

            <b>Summary: </b><span dangerouslySetInnerHTML={{ __html: item.summary }}/>
            {item.summaryTooLong ?
              <span className="badge badge-danger">{item.summaryLength}</span> : ""}<br/>

            {(isStory && item.chapters) ?
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

function mapStateToProps({ itemResponse }, ownProps) {
  if (itemResponse.original_id === ownProps.item.id) {
    return { item: _.merge(ownProps.item, itemResponse) };
  }
  return ownProps;
}

export default connect(mapStateToProps, { importItem })(Item);