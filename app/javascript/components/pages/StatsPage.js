import React, { Component } from 'react';
import { connect } from "react-redux";

import Col from "react-bootstrap/lib/Col";
import Card from "react-bootstrap/lib/Card";
import CardDeck from "react-bootstrap/lib/CardDeck";
import { Link } from "react-router-dom";

import { fetchStats } from "../../actions";
import { authors_path } from "../../config";


class StatsPage extends Component {
  constructor(props) {
    super(props);
    this.props.fetchStats();
    console.log(props);
  }

  componentDidMount = () => {
    this.props.fetchStats();
  };

  render() {
    const stats = this.props.stats;
    console.log(stats);
    if (Object.keys(stats).length > 0) {
      return (
        <Col>
          <h1>Archive stats</h1>

          <h2>Counts</h2>
          <CardDeck>
            <Card>
              <Card.Header>
                <Card.Title>Authors</Card.Title>
              </Card.Header>
              <Card.Body>
                <Card.Text><b>Total authors:</b> {stats.authors.table.all}</Card.Text>
                <Card.Text><b>Imported authors:</b> {stats.authors.table.imported}</Card.Text>
                <Card.Text><b>Marked do not import:</b> {stats.authors.table.dni}</Card.Text>
                <Card.Text><b>Not marked imported:</b> {stats.authors.table.not_imported}</Card.Text>
              </Card.Body>
            </Card>

            <Card>
              <Card.Header>
                <Card.Title>Authors by letter</Card.Title>
              </Card.Header>
              <Card.Body>
                <Card.Text><b>Total author groups:</b>
                  {stats.letters.table.all}</Card.Text>
                <Card.Text><b>Imported groups:</b>
                  {stats.letters.table.imported.length}<br/>
                  {stats.letters.table.imported.map((letter) => <Link key={letter} to={authors_path(letter)}/>)}
                </Card.Text>
                <Card.Text><b>Still to import:</b>
                  {stats.letters.table.not_imported.length}<br/>
                  {stats.letters.table.not_imported.map((letter) => <Link key={letter} to={authors_path(letter)}/>)}
                </Card.Text>
              </Card.Body>
            </Card>

            <Card>
              <Card.Header>
                <Card.Title>Stories</Card.Title>
              </Card.Header>
              <Card.Body>
                <Card.Text><b>Total stories:</b> {stats.stories.table.all}</Card.Text>
                <Card.Text><b>Imported stories:</b> {stats.stories.table.imported}</Card.Text>
                <Card.Text><b>Marked do not import:</b> {stats.stories.table.dni}</Card.Text>
                <Card.Text><b>Still to be imported:</b> {stats.stories.table.not_imported}</Card.Text>
              </Card.Body>
            </Card>

            <Card>
              <Card.Header>
                <Card.Title>Story links</Card.Title>
              </Card.Header>
              <Card.Body>
                <p><b>Total links:</b> {stats.story_links.table.all}</p>
                <p><b>Imported links:</b> {stats.story_links.table.imported}</p>
                <p><b>Marked do not import:</b> {stats.story_links.table.dni}</p>
                <p><b>Still to be imported:</b> {stats.story_links.table.not_imported}</p>
              </Card.Body>
            </Card>
          </CardDeck>
        </Col>
      );
    } else {
      return <div>Loading stats...</div>
    }
  }
}


function mapStateToProps(state) {
  return { stats: state.stats };
}

export default connect(mapStateToProps, { fetchStats })(StatsPage);