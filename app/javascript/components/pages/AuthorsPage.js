import React, { Component } from 'react';

import AlphabeticalPagination from "../pagination/AlphabeticalPagination";
import Authors from "../items/Authors";
import NumberPagination from "../pagination/NumberPagination";
import Col from "react-bootstrap/Col";
import { authors_path } from "../../config";
import { getReq } from "../../actions";

export default class AuthorsPage extends Component {
  constructor(props) {
    super(props);
    this.state = Object.assign({ pages: 0 }, this.props.data);
  }

  handleLetterChange = (letter) => {
    history.pushState(null, `Authors for ${letter}`, authors_path(letter));
    this.setState({ letter: letter, page: '1', selectedAuthor: undefined });
    this.getAuthors(letter, '1');
  };

  handlePageChange = (page) => {
    const letter = this.state.letter;
    history.pushState(null, `Authors for ${letter}, page ${page}`, authors_path(letter, page));
    this.setState({ page: page, selectedAuthor: undefined });
    this.getAuthors(letter, page);
  };

  handleAuthorSelect = (key) => {
    this.setState({ selectedAuthor: key });
  };

  getAuthors = (letter, page) => {
    const endpoint = `authors/letters/${letter}/${page}`;
    getReq(endpoint).then(res => {
      if (res.data) {
        this.setState({ authors: res.data });
        this.setPages();
      }
    })
      .catch(err => {
        console.log(JSON.stringify(err));
      })
  }

  setPages() {
    this.setState({ pages: Math.ceil(this.state.letter_counts[this.state.letter]["all"] / this.state.page_size) });
  }

  componentDidMount() {
    this.setPages();
  }

  componentDidUpdate() {
    if (this.state.selectedAuthor) {
      const element = document.getElementById(this.state.selectedAuthor);
      element.scrollIntoView({ behavior: 'smooth' });
    }
  }

  render() {
    const alphabeticalPagination = <AlphabeticalPagination letter={this.state.letter}
                                                           letters={this.state.letter_counts}
                                                           authors={this.state.authors}
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

        <Authors letter={this.state.letter} user={this.props.user} authors={this.state.authors}/>

        {numberPagination}
        {alphabeticalPagination}
      </Col>
    );
  }
}
