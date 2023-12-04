import React, { Component } from "react";
import Pagination from "react-bootstrap/Pagination";
import Dropdown from "react-bootstrap/Dropdown";
import { authors_path } from "../../config";

export default class NumberPagination extends Component {

  handlePageChange = (e, p) => {
    e.preventDefault();
    this.props.onPageChange(p)
  };

  getShownItems = (listItems, currentPage) => {
    const shownPages = 7;
		const halfPages = parseInt(shownPages / 2);
    const totalPages = listItems.length;
		
		let startIdx = -1;
		let endIdx = currentPage + halfPages;
		if (shownPages % 2 > 0) {
			startIdx = currentPage - halfPages - 1;
		} else {
			startIdx = currentPage - halfPages;
		}
		
		if (startIdx <= 0) {
			return listItems.slice(1, shownPages + 1);
		} else if (endIdx >= totalPages) {
			return listItems.slice(totalPages - shownPages - 1, totalPages - 1);
		} else {
			return listItems.slice(startIdx, endIdx);
		}
  }

  render() {
    const currentPageInt = parseInt(this.props.page);
    const pageList = [...Array(this.props.pages).keys()].map(p => p + 1);
    
    const listItems = pageList.map((p) => {
        const isCurrent = (p === currentPageInt);
        const props = {
          active: isCurrent,
          onClick: e => this.handlePageChange(e, p)
        };
        return <Pagination.Item key={p} href={authors_path(this.props.letter, p)} {...props}>{p}</Pagination.Item>
      }
    );

    const shownItems = this.getShownItems(listItems, currentPageInt);
    
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
            <Pagination.Prev {...props(currentPageInt - 1)} />
            {listItems[0]}
            <Pagination.Ellipsis />
            {shownItems}
            <Pagination.Ellipsis />
            {listItems[parseInt(this.props.pages) - 1]}
            <Pagination.Next {...props(currentPageInt + 1)} />
            <Dropdown className="page-item">
              <Dropdown.Toggle className="page-link" id="dropdown-basic-button">Jump to page...</Dropdown.Toggle>
              <Dropdown.Menu>
                {pageList.map((p) => {
                  if (p !== currentPageInt) {
                    return <Dropdown.Item key={`${p}-link`}
                                          onClick={e => this.handlePageChange(e, p)}>{p}</Dropdown.Item>
                  }
                })}
              </Dropdown.Menu>
            </Dropdown>
          </Pagination>
        </div>
      </nav>
    )
  }
}

