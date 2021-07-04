import React, { Component } from "react";

import Card from "react-bootstrap/Card";
import Alert from "react-bootstrap/Alert";
import Item from "./Item";

export default class Items extends Component {
  render() {
    // logStateAndProps("Items", "", this);
    if (this.props.data) {
      if (this.props.data.error) {
        return (
          <Alert variant="warning">
            <h4>{this.props.data.status}</h4>
            {this.props.data.error.map((m, i) => <span key={i}>{m}<br/></span>)}
          </Alert>
        )
      } else {
        const stories = this.props.data.stories;
        const links = this.props.data.story_links;
        return (
          <div className="items">
            {
              Object.values(stories).length > 0 ?
                <div>
                  <Card.Title>Stories</Card.Title>
                  {Object.entries(stories).map(([ id, s ]) => {
                    return <Item key={`story-${id}-${this.props.authorVersion}`}
                                 item={s}
                                 user={this.props.user}/>
                  })}
                </div> : ''
            }
            {
              Object.values(links).length > 0 ?
                <div>
                  <Card.Title>Story Links</Card.Title>
                  {Object.entries(links).map(([ id, s ]) => {
                    return <Item key={`link-${id}-${this.props.authorVersion}`}
                                 item={s}
                                 user={this.props.user}/>
                  })}
                </div> : ''
            }
          </div>
        )
      }
    } else {
      return (
        <Card>
          <Card.Title>No data</Card.Title>
          No data could be retrieved for this author.
        </Card>
      )
    }
  }
}
