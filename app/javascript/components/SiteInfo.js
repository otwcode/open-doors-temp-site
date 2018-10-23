import React from "react"
import PropTypes from "prop-types"
import Card from "react-bootstrap/lib/Card";
import { connect } from "react-redux";
import { fetchStats } from "../actions";

class SiteInfo extends React.Component {
  componentDidMount = () => {
    this.props.fetchStats(`/${this.props.config.key}`);
  };

  render() {
    const config = this.props.config;
    if (this.props.stats.stories) {
      const storiesLeft = this.props.stats.stories.table.not_imported;
      const storiesTotal = this.props.stats.stories.table.all;
      const linksLeft = this.props.stats.story_links.table.not_imported;
      const linksTotal = this.props.stats.story_links.table.all;
      return (
          <Card>
            <Card.Body>
              <Card.Text>Importing to <a href="http://{config.url}/collections/{config.collection_name}"
                                         target="_blank">
                http://{config.url}/collections/{config.collection_name}</a> as <strong>{config.archivist}</strong>.
                Sending emails is <strong>{config.send_email ? "ON" : "OFF"}</strong> and
                posting as drafts is <strong>{config.post_preview ? "ON" : "OFF"}</strong>
              </Card.Text>
              <Card.Text>
                <strong>{storiesLeft}</strong>/{storiesTotal} stories and <strong>{linksLeft}</strong>/{linksTotal} links
                still to be imported.
              </Card.Text>
            </Card.Body>
          </Card>
      )
    } else {
      return <div/>
    }
  }
}

SiteInfo.propTypes = {
  config: PropTypes.object
};

function mapStateToProps(state) {
  return { stats: state.stats };
}

export default connect(mapStateToProps, { fetchStats })(SiteInfo);

