import React from "react"
import PropTypes from "prop-types"
import Card from "react-bootstrap/lib/Card";

export default class SiteInfo extends React.Component {
  render () {
    const config =  this.props.config; 
    const storiesLeft = 'XX';
    const storiesTotal = 'XX';
    const linksLeft = 'XX';
    const linksTotal = 'XX';
    return (
      <Card>
        <Card.Body>
          <Card.Text>Importing to <a href="http://{config.url}/collections/{config.collection_name}" target="_blank">
            http://{config.url}/collections/{config.collection_name}</a> as <strong>{config.archivist}</strong>.
            Sending emails is <strong>{config.send_email ? "ON" : "OFF"}</strong> and
            posting as drafts is <strong>{config.post_preview ? "ON" : "OFF"}</strong>
          </Card.Text>
          <Card.Text>
            <strong>{storiesLeft}</strong>/{storiesTotal} stories and 
            <strong>{linksLeft}</strong>/{linksTotal} links still to be imported.
          </Card.Text>
        </Card.Body>
      </Card>
    )
  }
}

SiteInfo.propTypes = {
  config: PropTypes.object
};
