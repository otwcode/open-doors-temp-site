import React, { Component } from 'react';
import { Route, Link, BrowserRouter as Router, Switch } from 'react-router-dom'
import { Provider } from "react-redux";
import { createStore, applyMiddleware } from "redux";
import promise from "redux-promise";
import reducers from "../reducers/index";

import { ActionCableProvider } from 'react-actioncable-provider';
import Navigation from "./navigation/Navigation";
import SiteInfo from "./SiteInfo";
import Config from "../config";
import AuthorsPage from "./AuthorsPage";
import Container from "react-bootstrap/lib/Container";
import Row from "react-bootstrap/lib/Row";
import Col from "react-bootstrap/lib/Col";
import MessageBoard from "./MessageBoard";

const createStoreWithMiddleware = applyMiddleware(promise)(createStore);
const store = createStoreWithMiddleware(reducers);

export default class App extends Component {
  constructor(props) {
    super(props);
    this.state = this.props;
  }

  path = (subpath) => `/${Config.sitekey}${subpath}`;

  render() {
    console.log(this.path(''));
    return (
      <Provider store={store}>
        <div>
          <Navigation data={this.props}/>
          <SiteInfo config={this.state.config}/>
          <ActionCableProvider url={`ws://${window.location.host}/${Config.sitekey}/cable`}>
            <Container>
              <Row>
                <Router>
                  <Switch>
                    <Route path={`/${Config.sitekey}`} render={() => <AuthorsPage data={this.props} />} />
                    <Route component={() => <h1>Not found</h1>} />
                  </Switch>
                </Router>
                <Col xs lg={2}>
                  <MessageBoard type="info"/>
                </Col>
              </Row>
            </Container>
          </ActionCableProvider>
        </div>
      </Provider>
    );
  }
}

