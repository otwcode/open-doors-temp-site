import React, { Component } from 'react';

import AlphabeticalPagination from "../pagination/AlphabeticalPagination";
import Authors from "../items/Authors";
import NumberPagination from "../pagination/NumberPagination";
import Col from "react-bootstrap/lib/Col";
import { authors_path } from "../../config";

export default class AuthorsPage extends Component {
  constructor(props) {
    super(props);
    this.state = this.props.data;
  }

  handleLetterChange = (letter) => {
    history.pushState(null, `Authors for ${letter}`, authors_path(letter));
    this.setState({ letter: letter });
  };

  handlePageChange = (page) => {
    history.pushState(null, `Authors for ${letter}`, authors_path(this.state.letter, page));
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

        <Authors letter={this.state.letter} user={this.props.user} />

        {numberPagination}
        {alphabeticalPagination}
      </Col>
    );
  }
}
