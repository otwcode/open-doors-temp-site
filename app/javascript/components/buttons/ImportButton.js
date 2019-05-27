import React, { Component } from "react";
import Button from "react-bootstrap/lib/Button";
import * as PropTypes from "prop-types";

export class ImportButton extends Component {
  render() {
    return <Button variant={this.props.variant}
                   className={this.props.className}
                   disabled={this.props.disabled}
                   onClick={this.props.disabled ? null : this.props.clickHandler}>
      {this.props.contents}
    </Button>;
  }
}

ImportButton.defaultProps = {
  disabled: false,
  variant: "outline-primary",
  className: "import-button"
};

ImportButton.propTypes = {
  small: PropTypes.string,
  disabled: PropTypes.bool.isRequired,
  clickHandler: PropTypes.func.isRequired,
  contents: PropTypes.object,
  variant: PropTypes.string,
  className: PropTypes.string
};