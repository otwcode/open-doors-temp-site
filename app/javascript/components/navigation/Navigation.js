import React, { Component } from "react"
import PropTypes from "prop-types"
import UserNavigation from "./UserNavigation"
import Navbar from "react-bootstrap/Navbar";
import Nav from "react-bootstrap/Nav";
import NavDropdown from "react-bootstrap/NavDropdown";
import { sitekey } from "../../config";

class Navigation extends Component {
  data = this.props.data;
  authorsPath = `/${sitekey}/authors`;
  storiesPath = `/${sitekey}/stories`;
  linksPath = `/${sitekey}/links`;

  renderStories = () => {
    return (
      <NavDropdown title="Stories and links" id="basic-nav-dropdown" bg="primary">
        <NavDropdown.Item href={this.storiesPath}>Stories to be imported</NavDropdown.Item>
        <NavDropdown.Item href={this.storiesPath}>Stories NOT to be imported</NavDropdown.Item>
        <NavDropdown.Item href={this.storiesPath}>Imported stories</NavDropdown.Item>
        <NavDropdown.Divider/>
        <NavDropdown.Item href={this.linksPath}>Links to be bookmarked</NavDropdown.Item>
        <NavDropdown.Item href={this.linksPath}>Links NOT to be bookmarked</NavDropdown.Item>
        <NavDropdown.Item href={this.linksPath}>Broken links</NavDropdown.Item>
        <NavDropdown.Item href={this.linksPath}>Bookmarked links</NavDropdown.Item>
      </NavDropdown>
    )
  };

  render() {
    return (
      <Navbar bg="primary" variant="dark" expand="lg">
        <Navbar.Brand href={this.authorsPath}><img src={this.data.logo_path} style={{ width: 50 + "px" }}/></Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav"/>
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="mr-auto">
            <Nav.Link href={this.authorsPath}>Authors (use for importing)</Nav.Link>
            {this.renderStories()}
          </Nav>
          <UserNavigation current_user={this.data.current_user} />
        </Navbar.Collapse>
      </Navbar>
    )
  }
}

Navigation.propTypes = {
  data: PropTypes.object
};
export default Navigation
