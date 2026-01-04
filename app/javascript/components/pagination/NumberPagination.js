import React, { Component } from "react";
import Pagination from "react-bootstrap/Pagination";
import Dropdown from "react-bootstrap/Dropdown";
import { authors_path } from "../../config";

const DOTS = "...";

const range = (start, end) => {
  let length = end - start + 1;
  return Array.from({ length }, (_, idx) => idx + start);
};

export default class NumberPagination extends Component {

  handlePageChange = (e, p) => {
    e.preventDefault();
    this.props.onPageChange(p)
  };

  // Pagination logic adapted from https://www.freecodecamp.org/news/build-a-custom-pagination-component-in-react/
  getPaginationRange = (currentPage, totalPageCount, siblingCount, totalPageNumbers) => {
    if (totalPageNumbers >= totalPageCount) {
      return range(1, totalPageCount);
    }

    const leftSiblingIndex = Math.max(currentPage - siblingCount, 1);
    const rightSiblingIndex = Math.min(
      currentPage + siblingCount,
      totalPageCount
    );

    const shouldShowLeftDots = leftSiblingIndex > 2;
    const shouldShowRightDots = rightSiblingIndex < totalPageCount - 2;

    const firstPageIndex = 1;
    const lastPageIndex = totalPageCount;

    if (!shouldShowLeftDots && shouldShowRightDots) {
      let leftRange = range(1, totalPageNumbers);
      return [...leftRange, DOTS, totalPageCount];
    }

    if (shouldShowLeftDots && !shouldShowRightDots) {
      let rightRange = range(
        totalPageCount - totalPageNumbers + 1,
        totalPageCount
      );
      return [firstPageIndex, DOTS, ...rightRange];
    }

    if (shouldShowLeftDots && shouldShowRightDots) {
      let middleRange = range(leftSiblingIndex, rightSiblingIndex);
      return [firstPageIndex, DOTS, ...middleRange, DOTS, lastPageIndex];
    }
  }

  render() {
    const currentPageInt = parseInt(this.props.page);
    const totalPagesInt = parseInt(this.props.pages);
    const siblingCount = 3;
    const totalPageNumbers = 3 + 2 * siblingCount;
    const paginationRange = this.getPaginationRange(currentPageInt, totalPagesInt, siblingCount, totalPageNumbers);

    let dotCount = 0;
    const shownItems = paginationRange.map(p => {
        if (p === DOTS) {
          dotCount++;
          return <Pagination.Ellipsis key={`dot-${dotCount}`} />
        }

        const isCurrent = (p === currentPageInt);
        const props = {
          active: isCurrent,
          onClick: e => this.handlePageChange(e, p)
        };
        return <Pagination.Item key={p} href={authors_path(this.props.letter, p)} {...props}>{p}</Pagination.Item>
    });
    
    const props = p => {
      const isValid = (p > 0 && p <= this.props.pages);
      return { 
        disabled: !isValid, 
        href: authors_path(this.props.letter, p),
        onClick: e => this.handlePageChange(e, p)
      }
    };

    const getDropdown = () => {
      return (
        <Dropdown className="page-item">
          <Dropdown.Toggle className="page-link" id="dropdown-basic-button">Jump to page...</Dropdown.Toggle>
          <Dropdown.Menu>
            {[...Array(totalPagesInt).keys()].map(p => p + 1).map((p) => {
              if (p !== currentPageInt) {
                return <Dropdown.Item key={`${p}-link`}
                                      onClick={e => this.handlePageChange(e, p)}>{p}</Dropdown.Item>
              }
            })}
          </Dropdown.Menu>
        </Dropdown>
      )
    }
    const dropdown = (totalPageNumbers >= totalPagesInt) ? "" : getDropdown();

    return (
      <nav aria-label="Page labels">
        <div className="text-center">
          <Pagination className="justify-content-center">
            <Pagination.Prev {...props(currentPageInt - 1)} />
            {shownItems}
            <Pagination.Next {...props(currentPageInt + 1)} />
            {dropdown}
          </Pagination>
        </div>
      </nav>
    )
  }
}

