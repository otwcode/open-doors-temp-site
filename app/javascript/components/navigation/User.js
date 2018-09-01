import React from "react"
import PropTypes from "prop-types"
import {NavDropdown} from "./NavDropdown";

class User extends React.Component {
  render () {
    if (this.props.current_user) {
      return (
        <ul className="nav navbar-nav navbar-right">
          <li className="nav-item">
            <span className="navbar-text"
                  style={{padding: .5 + 'rem'}}>Signed in as <strong>{this.props.current_user.name}</strong></span>
          </li>
          <NavDropdown name="Admin">
            <a href="stats" className="dropdown-item">Stats</a>
            <a href={this.props.configPath} className="dropdown-item">Config</a>
          </NavDropdown>

          <li className="nav-item">
            <a className="nav-item" href={this.props.logoutPath}>Log out</a>
          </li>
        </ul>
      );
      
    } else {
      return (
        <ul className="nav navbar-nav navbar-right">
          <li className="nav-item">
            <a href={this.props.loginPath} className="nav-link">Log in</a>
          </li>
          <li className="nav-item">
            <a href={this.props.signupPath} className="nav-link">Sign up</a>
          </li>
        </ul>
      );
    }
  }
}

User.propTypes = {
  current_user: PropTypes.object,
  loginPath: PropTypes.string,
  logoutPath: PropTypes.string,
  signupPath: PropTypes.string,
  configPath: PropTypes.string
};
export default User
