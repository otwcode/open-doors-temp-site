import React, { Component } from "react";
import OverlayTrigger from "react-bootstrap/es/OverlayTrigger";
import Tooltip from "react-bootstrap/lib/Tooltip";
import Pagination from "react-bootstrap/lib/Pagination";
import Dropdown from "react-bootstrap/lib/Dropdown";
import DropdownButton from "react-bootstrap/lib/DropdownButton";

export default class AlphabeticalPagination extends React.Component {
  constructor(props) {
    super(props);
    this.state = this.props;
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
    const letters = Object.keys(this.props.authors);
    const linkUrl = l => `${this.props.root_path}/authors?letter=${l}`;
    const listItems = Object.entries(this.props.authors).map((kv) => {
        const [ l, as ] = kv;
        const numAuthors = as.length;
        const authorsWithImports = as.filter(a => (a.s_to_import + a.l_to_import > 0) && !a.imported).length;
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
              <a href={linkUrl(l)}
                 onClick={e => this.handleLetterChange(e, l)}
                 className={isDone ? "page-link text-dark bg-light" : "page-link"}>
                {l}{isCurrent ? <span className="sr-only"> (current)</span> : ""}
              </a>
            </OverlayTrigger>
          </li>)
      }
    );

    const prev = letters.findIndex(x => x === this.props.letter) - 1;
    const next = letters.findIndex(x => x === this.props.letter) + 1;
    const prevLink = prev < 0 ? '' : linkUrl(letters[ prev ]);
    const nextLink = next > letters.length - 1 ? '' : linkUrl(letters[ next ]);

    return (
      <div className="text-center">
        <Pagination className="justify-content-center">
          <Pagination.Prev disabled={prev < 0} href={prevLink}/>
          {listItems}
          <Pagination.Next disabled={next > letters.length - 1} href={nextLink}/>
          <DropdownButton variant="primary-outline" id="dropdown-basic-button"
                          title={`Scroll to...'`}>
            {Object.entries(this.props.authors).map((kv) => {
              const [ l, authors ] = kv;
              if (l === this.props.letter) {
                return authors.map(a => {
                  const key = `author-${a.id}`;
                  return <Dropdown.Item key={`${key}-link`}
                                        onClick={e => this.handleAuthorSelect(e, key)}>{a.name}</Dropdown.Item>
                })
              }
            })}
          </DropdownButton>
        </Pagination>
      </div>
    )
  }
}

