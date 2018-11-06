import React, { Component } from 'react';
import { connect } from "react-redux";

import AlphabeticalPagination from "./pagination/AlphabeticalPagination";
import Authors from "./items/Authors";
import NumberPagination from "./pagination/NumberPagination";
import Col from "react-bootstrap/lib/Col";
import Config from "../config";

export default class AuthorsPage extends Component {
  constructor(props) {
    super(props);
    this.state = this.props.data;
  }

  handleLetterChange = (letter) => {
    const url = `/${Config.sitekey}/authors?letter=${letter}`;
    history.pushState(null, `Authors for ${letter}`, url);
    this.setState({ letter: letter });
  };

  handlePageChange = (page) => {
    const url = `/${Config.sitekey}/authors?letter=${this.state.letter}&page=${page}`;
    history.pushState(null, `Authors for ${letter}`, url);
    this.setState({ page: page });
  };

  handleAuthorSelect = (key) => {
    this.setState({ selectedAuthor: key });
  };

  componentDidUpdate() {
    if (this.state.selectedAuthor) {
      const element = document.getElementById(this.state.selectedAuthor);
      element.scrollIntoView({ behavior: 'smooth' });
    }
  }

  render() {
    const alphabeticalPagination = <AlphabeticalPagination letter={this.state.letter}
                                                           authors={this.state.all_letters}
                                                           onAuthorSelect={this.handleAuthorSelect}
                                                           onLetterChange={this.handleLetterChange}/>;
    const numberPagination = (this.state.pages > 1) ?
      <NumberPagination letter={this.state.letter}
                        page={this.state.page}
                        pages={this.state.pages}
                        onPageChange={this.handlePageChange}/> : '';


    return (
      <Col>
        {alphabeticalPagination}
        {numberPagination}

        <Authors letter={this.state.letter} />

        {numberPagination}
        {alphabeticalPagination}
      </Col>
    );
  }
}
