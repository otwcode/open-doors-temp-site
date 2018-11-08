import React from "react"
import PropTypes from "prop-types"
import Card from "react-bootstrap/lib/Card";
import { connect } from "react-redux";
import { fetchStats } from "../actions";


class SiteInfo extends React.Component {
  componentDidMount = () => {
    this.props.fetchStats();
  };

  renderImportStats = () => {
    if (this.props.stats.stories) {
      const storiesLeft = this.props.stats.stories.table.not_imported;
      const storiesTotal = this.props.stats.stories.table.all;
      const linksLeft = this.props.stats.story_links.table.not_imported;
      const linksTotal = this.props.stats.story_links.table.all;
      return (
        <Card.Text>
          <strong>{storiesLeft}</strong>/{storiesTotal} stories and <strong>{linksLeft}</strong>/{linksTotal} links
          still to be imported.
        </Card.Text>
      )
    } else {
      return <Card.Text>Loading latest stats...</Card.Text>
    }
  };

  render() {
    const config = this.props.config;
    return (
      <Card>
        <Card.Body>
          <Card.Text>Importing to <a href="http://{config.url}/collections/{config.collection_name}"
                                     target="_blank">
            http://{config.url}/collections/{config.collection_name}</a> as <strong>{config.archivist}</strong>.
            Sending emails is <strong>{config.send_email ? "ON" : "OFF"}</strong> and
            posting as drafts is <strong>{config.post_preview ? "ON" : "OFF"}</strong>
          </Card.Text>
          {this.renderImportStats()}
        </Card.Body>
      </Card>
    )
  }
}

SiteInfo.propTypes = {
  config: PropTypes.object
};

function mapStateToProps(state) {
  return { stats: state.stats };
}

export default connect(mapStateToProps, { fetchStats })(SiteInfo);

