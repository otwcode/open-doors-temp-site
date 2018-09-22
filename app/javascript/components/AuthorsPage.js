import React, { Component } from 'react';
import { ActionCableProvider } from 'react-actioncable-provider';
import AlphabeticalPagination from "./pagination/AlphabeticalPagination";
import Navigation from "./navigation/Navigation";
import SiteInfo from "./SiteInfo";
import Authors from "./items/Authors";
import NumberPagination from "./pagination/NumberPagination";
import MessageBoard from "./MessageBoard";

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
    console.log(this.props);
    
    return (
      <div>
        <Navigation data={this.props}/>
        <SiteInfo config={this.state.config}/>
        <ActionCableProvider url={`ws://${window.location.host}${this.props.root_path}/cable`.replace('//', '/')}>
          <MessageBoard type="info"/>
        </ActionCableProvider>
        <div className="container">
          <AlphabeticalPagination root_path={this.props.root_path}
                                  letter={this.state.letter}
                                  authors={this.props.all_letters}
                                  onLetterChange={this.handleLetterChange}/>
          { this.props.pages > 1 ?
            <NumberPagination root_path={this.props.root_path}
                        letter={this.state.letter}
                        page={this.state.page}
                        pages={this.props.pages}
                        onPageChange={this.handlePageChange}/> : ''}
                        
            <Authors root_path={this.props.root_path}
                     authors={this.state.authors}/>

          { this.props.pages > 1 ?
            <NumberPagination letter={this.state.letter}
                      page={this.state.page}
                      pages={this.props.pages}
                      onPageChange={this.handlePageChange}/> : ''}
          <AlphabeticalPagination root_path={this.props.root_path}
                                  letter={this.state.letter}
                                  authors={this.props.all_letters}
                                  onLetterChange={this.handleLetterChange}/>
          
            
        </div>
      </div>
    );
  }
}

