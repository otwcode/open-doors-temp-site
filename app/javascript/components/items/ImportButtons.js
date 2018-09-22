import React, { Component } from "react";
import ButtonGroup from "react-bootstrap/lib/ButtonGroup";
import Button from "react-bootstrap/lib/Button";


export default class ImportButtons extends Component {

  handleImport = (e) => {
    console.log("handleImport");
    e.preventDefault();
    this.props.onImporting(e)
  };

  render() {
    const { isImporting } = this.props;

    return (
      <ButtonGroup width="100px" size="sm">
        <Button variant="outline-primary"
                disabled={isImporting}
                onClick={!isImporting ? (e) => this.handleImport(e) : null}>
          <i className="fa fa-upload"/> {isImporting ? "Importing..." : "Import All"}
        </Button>

        <Button variant="outline-success">
          <i className="fa fa-question-circle"/> Check All
        </Button>
        <Button variant="outline-danger">
          <i className="fa fa-times"/> Mark DNI
        </Button>
        <Button variant="outline-dark">
          <i className="fa fa-eye-slash"/> Clear msg
        </Button>
      </ButtonGroup>
    )
  }
}
