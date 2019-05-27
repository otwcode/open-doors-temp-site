import React, { Component } from "react";
import ButtonGroup from "react-bootstrap/lib/ButtonGroup";
import Button from "react-bootstrap/lib/Button";
import { ImportButton } from "./ImportButton";
import PropTypes from "prop-types";


export default class ImportButtons extends Component {

  handleImport = (e) => {
    e.preventDefault();
    this.props.onImporting(e)
  };

  handleCheck = (e) => {
    e.preventDefault();
    this.props.onChecking(e)
  };

  handleDNI = (e) => {
    e.preventDefault();
    this.props.onDNI(e)
  };

  importText = (text) => {
    if (this.props.isImported) {
      return <span><i className="fa fa-check-square-o"/> Imported</span>
    } else {
      return this.props.isImporting ?
        <span><i className="fa fa-clock-o"/> Importing...</span> :
        <span><i className="fa fa-upload"/> {text}</span>
    }
  };

  checkText = () => {
    return this.props.isImporting ?
      <span><i className="fa fa-clock-o"/> Checking...</span> :
      <span><i className="fa fa-question-circle"/> Check All</span>
  };


  dniText = () => {
    return <span><i className="fa fa-times"/> Mark DNI</span>;
  }

  render() {
    const { isImporting, isImported, isChecking } = this.props;

    return (
      <ButtonGroup width="100px" size="sm">
        <ImportButton variant="outline-primary"
                      disabled={isImporting || isImported}
                      clickHandler={(e) => this.handleImport(e)}
                      contents={this.importText(this.props.importText)}/>

        <ImportButton variant="outline-success"
                      disabled={isChecking}
                      clickHandler={(e) => this.handleCheck(e)}
                      contents={this.checkText()}/>

        <ImportButton variant="outline-danger"
                      disabled={isImported}
                      clickHandler={(e) => this.handleDNI(e)}
                      contents={this.dniText()}/>
        {this.props.children}
      </ButtonGroup>
    )
  }
}

ImportButtons.propTypes = {
  onImporting: PropTypes.func.isRequired,
  onChecking: PropTypes.func.isRequired,
  onDNI: PropTypes.func.isRequired,
  isImported: PropTypes.bool,
  isImporting: PropTypes.bool,
  importText: PropTypes.string,
};