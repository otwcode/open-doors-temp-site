import React from "react"
import PropTypes from "prop-types"
export default class SiteInfo extends React.Component {
  render () {
    const config =  this.props.config; 
    return (
        <div className="card">
        <div className="card-block">
        <p className="card-text">
        Importing to <a href="http://{config.url}/collections/{config.collection_name}" target="_blank">
        http://{config.url}/collections/{config.collection_name}</a> as <strong>{config.archivist}</strong>.
        Sending emails is <strong>{config.send_email ? "ON" : "OFF"}</strong> and
        posting as drafts is <strong>{config.post_preview ? "ON" : "OFF"}</strong>
    </p>
    </div>
    </div>
    );
  }
}

SiteInfo.propTypes = {
  config: PropTypes.object
};
