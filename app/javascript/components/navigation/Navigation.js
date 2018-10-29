import React, { Component } from "react"
import PropTypes from "prop-types"
import UserNavigation from "./UserNavigation"
import Navbar from "react-bootstrap/lib/Navbar";
import Nav from "react-bootstrap/lib/Nav";
import NavDropdown from "react-bootstrap/lib/NavDropdown";

class Navigation extends Component {
  render() {
    const data = this.props.data;
    const authorsPath = `${data.root_path}/authors`;
    const storiesPath = `${data.root_path}/stories`;
    const linksPath = `${data.root_path}/links`;
    return (
      <Navbar bg="primary" variant="dark" expand="lg">
        <Navbar.Brand href={authorsPath}><img src={data.logo_path} style={{ width: 50 + "px" }}/></Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav"/>
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="mr-auto">
            <Nav.Link href={authorsPath}>Authors (use for importing)</Nav.Link>
            <NavDropdown title="Stories and links" id="basic-nav-dropdown" bg="primary">
              <NavDropdown.Item href={storiesPath}>Stories to be imported</NavDropdown.Item>
              <NavDropdown.Item href={storiesPath}>Stories NOT to be imported</NavDropdown.Item>
              <NavDropdown.Item href={storiesPath}>Imported stories</NavDropdown.Item>
              <NavDropdown.Divider/>
              <NavDropdown.Item href={linksPath}>Links to be bookmarked</NavDropdown.Item>
              <NavDropdown.Item href={linksPath}>Links NOT to be bookmarked</NavDropdown.Item>
              <NavDropdown.Item href={linksPath}>Broken links</NavDropdown.Item>
              <NavDropdown.Item href={linksPath}>Bookmarked links</NavDropdown.Item>
            </NavDropdown>
          </Nav>
          <UserNavigation current_user={data.current_user}
                          root_path={data.root_path} />
        </Navbar.Collapse>
      </Navbar>
    )
  }
}

Navigation.propTypes = {
  data: PropTypes.object
};
export default Navigation
