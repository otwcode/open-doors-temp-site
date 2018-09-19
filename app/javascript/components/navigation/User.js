import React from "react"
import NavDropdown from "react-bootstrap/lib/NavDropdown";
import Nav from "react-bootstrap/lib/Nav";

class User extends React.Component {
  render () {
    if (this.props.current_user) {
      const logoutPath = `${this.props.root_path}/logout`; 
      const statsPath = `${this.props.root_path}/stats`;
      return (
        <Nav>
          <Nav.Item>
            <span className="navbar-text" 
                  style={{ paddingRight: '20 px' }}>Signed in as <strong>{this.props.current_user}</strong>&nbsp;</span>
          </Nav.Item>
          <NavDropdown title="Admin" id="admin-nav-dropdown">
            <NavDropdown.Item href={statsPath}>Stats</NavDropdown.Item>
            <NavDropdown.Item href={this.props.config_path}>Config</NavDropdown.Item>
          </NavDropdown>
            <Nav.Link className="nav-item" href={logoutPath}>Log out</Nav.Link>
        </Nav>
      );
      
    } else {
      const loginPath = `${this.props.root_path}/login`; 
      const signupPath = `${this.props.root_path}/signup`; 
      return (
        <ul className="nav navbar-nav navbar-right">
          <li className="nav-item">
            <a href={loginPath} className="nav-link">Log in</a>
          </li>
          <li className="nav-item">
            <a href={signupPath} className="nav-link">Sign up</a>
          </li>
        </ul>
      );
    }
  }
}

export default User
