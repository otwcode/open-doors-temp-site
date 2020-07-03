import React, { Component } from "react";
import ButtonGroup from "react-bootstrap/ButtonGroup";
import Button from "react-bootstrap/Button";


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

  importText = () => {
    if (this.props.isImported) {
      return <span><i className="fa fa-check-square-o"/> Imported</span>
    } else {
      return this.props.isImporting ?
        <span><i className="fa fa-clock-o"/> Importing...</span> :
        <span><i className="fa fa-upload"/> Import All</span>
    }
  };

  checkText = () => {
    return this.props.isImporting ?
      <span><i className="fa fa-clock-o"/> Checking...</span> :
      <span><i className="fa fa-question-circle"/> Check All</span>
  };

  render() {
    const { isImporting, isImported, isChecking } = this.props;

    return (
      <ButtonGroup width="100px" size="sm">
        <Button variant="outline-primary"
                className="import-button"
                disabled={isImporting || isImported}
                onClick={!isImporting ? (e) => this.handleImport(e) : null}>
          {this.importText()}
        </Button>

        <Button variant="outline-success"
                className="import-button"
                disabled={isChecking}
                onClick={!isChecking ? (e) => this.handleCheck(e) : null}>
          {this.checkText()}
        </Button>

        <Button variant="outline-danger"
                className="import-button"
                disabled={isImported}
                onClick={(e) => this.handleDNI(e)}>
          <i className="fa fa-times"/> Mark DNI
        </Button>
      </ButtonGroup>
    )
  }
}
