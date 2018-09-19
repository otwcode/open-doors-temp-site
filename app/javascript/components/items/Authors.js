import React, { Component } from "react";
import Collapse from "react-bootstrap/lib/Collapse";
import Card from "react-bootstrap/lib/Card";
import axios from "axios";
import Items from "./Items";
import ImportButtons from "./ImportButtons";
import ButtonToolbar from "react-bootstrap/lib/ButtonToolbar";
import Alert from "react-bootstrap/lib/Alert";

class Author extends Component {
  constructor(props, context) {
    super(props, context);

    this.state = {
      open: false,
      hasError: false,
      isImporting: false,
      data: {}
    };
  }

  componentDidMount = () => {
    axios
      .get(`${this.props.root_path}/items/author/${this.props.author.id}`)
      .then((res) => {
        this.setState({ data: res.data });
      })
  };

  handleAuthorClick = () => {
    this.setState({ open: !this.state.open })
  };

  handleImporting = (e) => {
    e.preventDefault();
    e.stopPropagation();
    e.nativeEvent.stopImmediatePropagation(); // stop it toggling the author
    this.setState({ isImporting: true }, () => {
      axios
        .post(`${this.props.root_path}/authors/cable/${this.props.author.id}`,
          {},
          {
            headers: {
              'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
              'Content-Type':  'application/json',
            }
          })
        .then(res => {
          this.setState({
            hasError: false,
            message: res.data.message
          });
        })
        .catch(err =>{
          console.log(err);
          this.setState({
            hasError: true,
            message: err.response.statusText
          })}
        )
        .then(() => this.setState({ isImporting: false }))
      ;
    });
  };

  render() {
    const { open, message, hasError } = this.state;
    const key = `author-${this.props.author.id}`;
    const headerClass = this.state.isImporting ? "importing" : "";
    const msgAlert = message ? <Alert key={`${key}-msg`} variant={hasError ? "danger" : "success"}>{message}</Alert> : <span/>;

    return (
      <Card key={key}>
        <a name={this.props.author.name.replace(' ', '_').toLowerCase()}/>
        <Card.Header onClick={this.handleAuthorClick}
                     aria-controls="example-collapse-text"
                     aria-expanded={open}
                     className={headerClass}
        >
          <ButtonToolbar className="justify-content-between">
            {this.props.author.name}

            <ImportButtons isImporting={this.state.isImporting} onImporting={this.handleImporting}/>
          </ButtonToolbar>
          {msgAlert}
        </Card.Header>

        <Collapse in={this.state.open}>
          <Card.Body id="example-collapse-text">
            <Items key={`${key}-items`} data={this.state.data}/>
          </Card.Body>
        </Collapse>
      </Card>
    )
  }
}

export default class Authors extends Component {
  render() {
    return (
      <div>
        {this.props.authors.map(a => <Author key={a.id} author={a} root_path={this.props.root_path}/>)}
      </div>
    )
  }
}
