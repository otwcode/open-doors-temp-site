import React from "react"
import PropTypes from "prop-types"
import User from "./User"
import {NavDropdown} from "./NavDropdown";

const NavItem = props => {
  const pageURI = window.location.pathname+window.location.search;
  const liClassName = (props.path === pageURI) ? "nav-item active" : "nav-item";
  const aClassName = props.disabled ? "nav-link disabled" : "nav-link";
  return (
    <li className={liClassName}>
      <a href={props.path} className={aClassName}>
        {props.name}
        {(props.path === pageURI) ? (<span className="sr-only">(current)</span>) : ''}
      </a>
    </li>
  );
};


class Navigation extends React.Component {
  render () {
    console.log(this.props);
    return (
      <nav className="navbar navbar-toggleable-sm navbar-inverse bg-primary">
        <button className="navbar-toggler navbar-toggler-right" type="button" data-toggle="collapse"
                data-target="#navbarMainMenu" aria-controls="navbarMainMenu" aria-expanded="false" aria-label="Toggle navigation">
          <span className="navbar-toggler-icon"></span>
        </button>
        <a className="navbar-brand" href={this.props.authors_path}>
          <img src={this.props.logo_path} style={{width: 50 + "px"}}/>
        </a>

        <div className="collapse navbar-collapse" id="navbarMainMenu">
          <ul className="navbar-nav mr-auto">
            <NavItem path={this.props.authors_path} name="Works by Author (use for importing)" />

            <NavDropdown name="Stories">
              <a className="dropdown-item" href={this.props.authors_path + "?letter=" + this.props.letter}>Stories to be imported</a>
              <a className="dropdown-item" href={this.props.authors_path + "?letter=" + this.props.letter}>Stories NOT to be imported</a>
              <a className="dropdown-item" href={this.props.authors_path + "?letter=" + this.props.letter}>Imported stories</a>
            </NavDropdown>

            <li className="nav-item dropdown">
              <a className={this.props.controller === "bookmarks" ? "nav-link dropdown-toggle active" : "nav-link dropdown-toggle"}
                 href={this.props.authors_path + "?letter=" + this.props.letter} id="navbarDropdownStories"
                 data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                Stories
              </a>
              <div className="dropdown-menu" aria-labelledby="navbarDropdownStories">
                <a className="dropdown-item" href={this.props.authors_path + "?letter=" + this.props.letter}>Stories to be imported</a>
                <a className="dropdown-item" href={this.props.authors_path + "?letter=" + this.props.letter}>Stories NOT to be imported</a>
                <a className="dropdown-item" href={this.props.authors_path + "?letter=" + this.props.letter}>Imported stories</a>
              </div>
            </li>

            <li className="nav-item dropdown">
              <a className={this.props.controller === "bookmarks" ? "nav-link dropdown-toggle active" : "nav-link dropdown-toggle"}
                 href={this.props.authors_path}
                 id="navbarDropdownBookmarks" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                External links
              </a>
              <div className="dropdown-menu" aria-labelledby="navbarDropdownBookmarks">
                <a className="dropdown-item" href={this.props.authors_path + "?letter=" + this.props.letter}>Links to be bookmarked</a>
                <a className="dropdown-item" href={this.props.authors_path + "?letter=" + this.props.letter}>Links NOT to be bookmarked</a>
                <a className="dropdown-item" href={this.props.authors_path + "?letter=" + this.props.letter}>Broken links</a>
                <a className="dropdown-item" href={this.props.authors_path + "?letter=" + this.props.letter}>Bookmarked links</a>
              </div>
            </li>
          </ul>
          <User current_user={this.props.current_user} 
                loginPath={this.props.login_path} 
                logoutPath={this.props.logout_path} 
                signupPath={this.props.signup_path}
                configPath={this.props.config_path}
          />
        </div>
      </nav>
    );
  }
}

Navigation.propTypes = {
  controller: PropTypes.string,
  letter: PropTypes.string,
  logo_path: PropTypes.string,
  config: PropTypes.object,
  current_user: PropTypes.object,
  logout_path: PropTypes.string,
  login_path: PropTypes.string,
  signup_path: PropTypes.string,
  authors_path: PropTypes.string,
  config_path: PropTypes.string
};
export default Navigation
