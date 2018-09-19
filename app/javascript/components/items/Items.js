import React, { Component } from "react";
import Card from "react-bootstrap/lib/Card";
import Collapse from "react-bootstrap/lib/Collapse";
import SafeAnchor from "react-bootstrap/lib/SafeAnchor";
import Tooltip from "react-bootstrap/lib/Tooltip";
import OverlayTrigger from "react-bootstrap/es/OverlayTrigger";

class Item extends Component {
  constructor(props) {
    super(props);
    this.state = {
      open: this.props.open,
    };
  }

  handleAuthorClick = () => {
    this.setState({ open: !this.state.open })
  };

  render() {
    const item = this.props.item;
    const isStory = this.props.isStory;
    return (
      <div>
        <OverlayTrigger
          placement="bottom"
          overlay={
            <Tooltip id="tooltip">id: {item.id}</Tooltip>
          }
        >
        <SafeAnchor onClick={this.handleAuthorClick}
                    aria-controls="blurb"
                    aria-expanded={open}>
          {this.props.item.title}</SafeAnchor>
        </OverlayTrigger>
        <Collapse in={this.state.open}>
          <div id="blurb">
            <b>Rating:</b> {item.rating || "None"}<br/>
            <b>Warnings:</b> {item.warnings || "None"}<br/>
            <b>Categories:</b> {item.categories || "None"}<br/>
            <b>Fandoms:</b> {item.fandoms || "None"}<br/>
            <b>Relationships:</b> {item.relationships || "None"}<br/>
            <b>Characters:</b> {item.characters || "None"}<br/>
            <b>Tags:</b> {item.tags || "None"}<br/>
            <b>Date:</b> {item.date || "No date"}
            {isStory &&
            <span>- <b>Updated:</b> {item.updated || "No update date set"}</span>
            }
            <br/>

            <b>Summary: </b><span dangerouslySetInnerHTML={{ __html: item.summary }}/><br/>

            {/*{isStory &&*/}
            {/*<ol>*/}
            {/*{item.chapters.map((chapter) =>*/}
            {/*<li>*/}
            {/*<a href={chapter.path}>chapter.title</a>*/}
            {/*</li>)*/}
            {/*}*/}
            {/*</ol>}*/}
          </div>
        </Collapse>
      </div>
    )
  }
}

export default class Items extends Component {
  render() {
    const stories = this.props.data.stories;
    const links = this.props.data.story_links;
    return (
      <div className="items">
        {
          stories && stories.length ?
          <div>
            <Card.Title>Stories</Card.Title>
            {stories.map((s) => <Item key={`story-${s.id}`} item={s} isStory={true}/>)}
          </div>: ''
        }
        {
          links && links.length ?
          <div>
            <Card.Title>Story Links</Card.Title>
            {links.map((s) => <Item key={`link-${s.id}`} item={s} isStory={false}/>)}
          </div> : ''
        }
      </div>
    )
  }
}
