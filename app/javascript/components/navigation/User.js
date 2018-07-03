import React from "react"
import PropTypes from "prop-types"

class User extends React.Component {
  render () {
    if (this.props.current_user) {
      return (
        <ul className="nav navbar-nav navbar-right">
          <li className="nav-item">
            <span className="navbar-text"
                  style="padding: .5rem">Signed in as <strong>{this.props.current_user.name}</strong></span>
          </li>
        </ul>
      );
      // <li className="nav-item">
      //   <li className="nav-item dropdown">
      //     <a className="nav-link dropdown-toggle <%= "active" if params[:controller] == "stats" || params[:controller] == "archive_config" %>" href=""
      //        id="navbarDropdownAdmin" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      //       Admin
      //     </a>
      //     <div className="dropdown-menu" aria-labelledby="navbarDropdownAdmin">
      //       <%= link_to "Stats", stats_path, class: "dropdown-item" %>
      //       <%= link_to "Config", archive_config_path(@archive_config), class: "dropdown-item" %>
      //     </div>
      //   </li>
      //
      // </li>
      // <li className="nav-item">
      //   <%= link_to "Log out", logout_path, class: "nav-link" %>
      // </li>
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
  signupPath: PropTypes.string
};
export default User
