import React, { Component } from "react";
import Alert from "react-bootstrap/lib/Alert";
import * as PropTypes from "prop-types";

export class MessageAlert extends Component {
  render() {
    return <Alert variant={this.props.hasError ? "danger" : "success"} className="alert-dismissible"
                  hidden={this.props.hidden}>
      {<ul>{
        this.props.msg.map((item, idx) => <li key={idx}>{item}</li>)
      }</ul>}
      <button type="button"
              className="close"
              data-dismiss="alert"
              aria-label="Close"
              onClick={this.props.onClick}>
        <span aria-hidden="true">&times;</span>
      </button>
    </Alert>;
  }
}

MessageAlert.propTypes = {
  hasError: PropTypes.bool,
  hidden: PropTypes.any,
  msg: PropTypes.any,
  messages: PropTypes.func,
  onClick: PropTypes.func
};