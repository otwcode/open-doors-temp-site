import React, { Component } from "react";
import Pagination from "react-bootstrap/Pagination";
import { authors_path } from "../../config";

export default class NumberPagination extends Component {

  handlePageChange = (e, p) => {
    e.preventDefault();
    this.props.onPageChange(p)
  };

  render() {
    const listItems = [...Array(this.props.pages).keys()].map(p => p + 1).map((p) => {
        const isCurrent = (p === this.props.page);
        const props = {
          active: isCurrent,
          onClick: e => this.handlePageChange(e, p)
        };
        return <Pagination.Item key={p} href={authors_path(this.props.letter, p)} {...props}>{p}</Pagination.Item>
      }
    );
    const props = p => {
      const isValid = (p > 0 && p <= this.props.pages);
      return { 
        disabled: !isValid, 
        href: authors_path(this.props.letter, p),
        onClick: e => this.handlePageChange(e, p)
      }
    };

    return (
      <nav aria-label="Page labels">
        <div className="text-center">
          <Pagination className="justify-content-center">
            <Pagination.Prev {...props(this.props.page - 1)} />
            {listItems}
            <Pagination.Next {...props(parseInt(this.props.page) + 1)} />
          </Pagination>
        </div>
      </nav>)
  }
}

