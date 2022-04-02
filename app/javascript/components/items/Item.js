import React, { Component } from "react";
import { connect } from "react-redux";
import { importItem, checkItem } from "../../actions";

import Card from "react-bootstrap/Card";
import ButtonToolbar from "react-bootstrap/ButtonToolbar";
import OverlayTrigger from "react-bootstrap/OverlayTrigger";
import Tooltip from "react-bootstrap/Tooltip";
import ImportButtons from "../buttons/ImportButtons";
import Button from "react-bootstrap/Button";
import Collapse from "react-bootstrap/Collapse";
import { sitekey } from "../../config";
import { MessageAlert } from "./MessageAlert";
import { logStateAndProps } from "../../utils/logging";

class Item extends Component {
  constructor(props) {
    super(props);
    this.state = {
      open: this.props.open,
      isImporting: false,
      isImported: this.props.item.imported
    };
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    // logStateAndProps("Item componentDidUpdate", this.props.item.title, this);
    if (this.props.item !== prevProps.item) {
      this.setState(Object.assign(this.state, {
        messages: this.props.item.messages,
        hasError: !this.props.item.success,
        isImported: this.props.item.imported,
        data: this.props.item
      }))
    }
  }

  stopEvents = (e) => {
    e.preventDefault();
    e.stopPropagation();
  };

  handleItemClick = () => {
    this.setState({ open: !this.state.open })
  };

  handleImporting = (e) => {
    this.stopEvents(e);
    this.setState(
      { isImporting: true, hideAlert: true },
      () => {
        this.props.importItem(this.props.item.id, this.props.type)
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
    this.setState(
      { isChecking: true, hideAlert: true },
      () => {
        this.props.checkItem(this.props.item.id, this.props.type)
          .then(() => this.setState({
            hideAlert: false,
            isChecking: false,
            isImported: this.props.item.imported,
            hasError: !this.props.item.success
          }))
      }
    );
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
    const { isImporting, isChecking } = this.state;
    const { item } = this.props;
    const isStory = !_.isUndefined(item.chapters)
    // logStateAndProps("Item", item.name, this);
    const key = isStory ? `story-${item.id}` : `link-${item.id}`;
    const headerClass = (isImporting ? " importing" : "") + (isChecking ? " checking" : "");
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
                {/*this.successIcon(item)*/}
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
                             onImporting={this.handleImporting}
                             showText={false}
              >
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
            <b>Notes: </b><span dangerouslySetInnerHTML={{ __html: item.notes }}/><br/>
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

  successIcon(item) {
    if (item.success === false) {
        return <OverlayTrigger
          placement="top"
          overlay={<Tooltip id="tooltip">This item recently failed to import</Tooltip>}>
          <i className="fa fa-times-circle" style={{ marginRight: '0.2em'}}/>
        </OverlayTrigger>
    }
    if (item.success === true) {
      return <OverlayTrigger
        placement="top"
        overlay={<Tooltip id="tooltip">This item was recently imported or checked</Tooltip>}>
        <i className="fa fa-check-circle" style={{ marginRight: '0.2em' }}/>
      </OverlayTrigger>
    } else return "";
  }
}

// Receives the output of the reducer and merges with the item object
// note that successive item responses accumulate in the itemResponses object
function mapStateToProps({ itemResponse }, ownProps) {
  const current_item_id = ownProps.item.id ? ownProps.item.id.toString() : ownProps.item.id;
  const response_ids = Object.keys(itemResponse)

  if (response_ids.find((id) => current_item_id === id)) {
    return { item: _.merge(ownProps.item, itemResponse[ current_item_id ]) };
  }
  return ownProps;
}

// link to the Redux action
export default connect(mapStateToProps, { importItem, checkItem })(Item);