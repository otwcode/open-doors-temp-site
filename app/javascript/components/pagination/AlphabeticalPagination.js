import React, { Component } from "react";
import OverlayTrigger from "react-bootstrap/OverlayTrigger";
import Tooltip from "react-bootstrap/Tooltip";
import Pagination from "react-bootstrap/Pagination";
import Dropdown from "react-bootstrap/Dropdown";
import { authors_path } from "../../config";
import { logStateAndProps } from "../../utils/logging";

export default class AlphabeticalPagination extends React.Component {
  constructor(props) {
    super(props);
  }

  handleLetterChange = (e, l) => {
    e.preventDefault();
    this.props.onLetterChange(l)
  };

  handleAuthorSelect = (e, key) => {
    e.preventDefault();
    this.props.onAuthorSelect(key);
  };

  render() {
    const listItems = Object.entries(this.props.letters).map((kv) => {
        const [ l, counts ] = kv;
        const numAuthors = counts.all;
        const authorsWithImports = counts.imports;
        const isCurrent = (l === this.props.letter);
        const isDone = authorsWithImports === 0;

        return (
          <li key={l} className={`page-item ${isCurrent ? "active" : ""}`}>
            <OverlayTrigger
              placement="bottom"
              overlay={
                <Tooltip id="tooltip">{`${l}: ${authorsWithImports}/${numAuthors} to import`}</Tooltip>
              }
            >
              <a href={authors_path(l)}
                 onClick={e => this.handleLetterChange(e, l)}
                 className={isDone ? "page-link text-dark bg-light" : "page-link"}>
                {l}{isCurrent ? <span className="sr-only"> (current)</span> : ""}
              </a>
            </OverlayTrigger>
          </li>)
      }
    );

    const letters = Object.keys(this.props.letters);
    const letterIndex = letters.findIndex(x => x === this.props.letter);
    const prev = letterIndex - 1;
    const next = letterIndex + 1;
    const prevLink = prev < 0 ? '' : authors_path(letters[ prev ]);
    const nextLink = next > letters.length - 1 ? '' : authors_path(letters[ next ]);

    return (
      <div className="text-center">
        <Pagination className="flex-wrap justify-content-center">
          <Pagination.Prev disabled={prev < 0} href={prevLink}/>
          {listItems}
          <Pagination.Next disabled={next > letters.length - 1} href={nextLink}/>
          <Dropdown className="page-item">
            <Dropdown.Toggle className="page-link" id="dropdown-basic-button">Scroll to...</Dropdown.Toggle>
            <Dropdown.Menu>
              {Object.entries(this.props.letters).map((kv) => {
                const [ l, counts ] = kv;
                if (l === this.props.letter) {
                  return this.props.authors.map(a => {
                    const key = `author-${a.id}`;
                    return <Dropdown.Item key={`${key}-link`}
                                          onClick={e => this.handleAuthorSelect(e, key)}>{a.name}</Dropdown.Item>
                  })
                }
              })}
            </Dropdown.Menu>
          </Dropdown>
        </Pagination>
      </div>
    )
  }
}
