import React, { Component } from 'react';
import { Route, BrowserRouter as Router, Switch } from 'react-router-dom'
import { Provider } from "react-redux";
import { createStore, applyMiddleware, compose } from "redux";
import promise from "redux-promise";
import reducers from "../reducers/index";

import { ActionCableProvider } from 'react-actioncable-provider';
import Navigation from "./navigation/Navigation";
import SiteInfo from "./SiteInfo";
import { sitekey } from "../config";
import { ws_protocol } from "../config";
import AuthorsPage from "./pages/AuthorsPage";
import Container from "react-bootstrap/Container";
import Row from "react-bootstrap/Row";
import MessageBoard from "./MessageBoard";
import StatsPage from "./pages/StatsPage";

const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
const createStoreWithMiddleware = composeEnhancers(applyMiddleware(promise))(createStore);
const store = createStoreWithMiddleware(reducers);

export default class App extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <Provider store={store}>
        <div>
          <Navigation data={this.props}/>
          <SiteInfo config={this.props.config}/>
          <ActionCableProvider url={`${ws_protocol}${window.location.host}/${sitekey}/cable`}>
            <Container fluid={true}>
              <Row>
                <Router>
                  <Switch>
                    <Route path={`/${sitekey}`} exact
                           render={() => <AuthorsPage data={this.props} user={this.props.current_user} />} />
                    <Route path={`/${sitekey}/authors`}
                           render={() => <AuthorsPage data={this.props} user={this.props.current_user} />} />
                    <Route path={`/${sitekey}/stats`}
                           render={() => <StatsPage/>} />
                    <Route component={() => <h1>Not found</h1>} />
                  </Switch>
                </Router>
                { this.props.current_user ? <MessageBoard type="info"/> : "" }
              </Row>
            </Container>
          </ActionCableProvider>
        </div>
      </Provider>
    );
  }
}

