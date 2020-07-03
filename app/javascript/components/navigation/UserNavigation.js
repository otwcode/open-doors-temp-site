import React from "react"
import NavDropdown from "react-bootstrap/NavDropdown";
import Nav from "react-bootstrap/Nav";
import { sitekey } from "../../config";

class UserNavigation extends React.Component {
  configPath = `/${sitekey}/config`;
  logoutPath = `/${sitekey}/logout`;
  statsPath = `/${sitekey}/stats`;
  loginPath = `/${sitekey}/login`;
  signupPath = `/${sitekey}/signup`;
  render () {
    if (this.props.current_user) {
      return (
        <Nav>
          <Nav.Item>
            <span className="navbar-text"
                  style={{ paddingRight: '20 px' }}>Signed in as <strong>{this.props.current_user}</strong>&nbsp;</span>
          </Nav.Item>
          <NavDropdown title="Admin" id="admin-nav-dropdown">
            <NavDropdown.Item href={this.statsPath}>Stats</NavDropdown.Item>
            <NavDropdown.Item href={this.configPath}>Config</NavDropdown.Item>
          </NavDropdown>
            <Nav.Link className="nav-item" href={this.logoutPath}>Log out</Nav.Link>
        </Nav>
      );

    } else {
      return (
        <ul className="nav navbar-nav navbar-right">
          <li className="nav-item">
            <a href={this.loginPath} className="nav-link">Log in</a>
          </li>
          <li className="nav-item">
            <a href={this.signupPath} className="nav-link">Sign up</a>
          </li>
        </ul>
      );
    }
  }
}

export default UserNavigation
