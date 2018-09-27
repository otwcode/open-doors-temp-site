import React, { Component } from 'react';
import { ActionCableProvider } from 'react-actioncable-provider';
import AlphabeticalPagination from "./pagination/AlphabeticalPagination";
import Navigation from "./navigation/Navigation";
import SiteInfo from "./SiteInfo";
import Authors from "./items/Authors";
import NumberPagination from "./pagination/NumberPagination";
import MessageBoard from "./MessageBoard";
import Container from "react-bootstrap/lib/Container";
import Row from "react-bootstrap/lib/Row";
import Col from "react-bootstrap/lib/Col";

export default class AuthorsPage extends Component {
  constructor(props) {
    super(props);
    this.state = this.props;
  }

  handleLetterChange = (letter) => {
    this.setState({ letter: letter });
    window.location = `${this.props.root_path}/authors?letter=${letter}`;
  };

  handlePageChange = (page) => {
    this.setState({ page: page });
    window.location = `${this.props.root_path}/authors?letter=${this.state.letter}&page=${page}`;
  };

  render() {
    return (
      <div>
        <Navigation data={this.props}/>
        <SiteInfo config={this.state.config}/>
        <ActionCableProvider url={`ws://${window.location.host}${this.props.root_path}/cable`.replace('//', '/')}>
          <Container>
            <Row>
              <Col>
                <AlphabeticalPagination root_path={this.props.root_path}
                                        letter={this.state.letter}
                                        authors={this.props.all_letters}
                                        onLetterChange={this.handleLetterChange}/>
                {this.props.pages > 1 ?
                  <NumberPagination root_path={this.props.root_path}
                                    letter={this.state.letter}
                                    page={this.state.page}
                                    pages={this.props.pages}
                                    onPageChange={this.handlePageChange}/> : ''}

                <Authors root_path={this.props.root_path}
                         authors={this.state.authors}/>

                {this.props.pages > 1 ?
                  <NumberPagination letter={this.state.letter}
                                    page={this.state.page}
                                    pages={this.props.pages}
                                    onPageChange={this.handlePageChange}/> : ''}
                <AlphabeticalPagination root_path={this.props.root_path}
                                        letter={this.state.letter}
                                        authors={this.props.all_letters}
                                        onLetterChange={this.handleLetterChange}/>
              </Col>
              <Col xs lg={2}>
                <MessageBoard type="info"/>
              </Col>
            </Row>
          </Container>
        </ActionCableProvider>
      </div>
    );
  }
}

