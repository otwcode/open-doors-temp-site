import axios from "axios";
import { sitekey } from "../config";

export const GET_SITE_STATS = "get_site_stats";
export const GET_AUTHOR_ITEMS = "get_author_items";
export const IMPORT_AUTHOR = "import_author";


function getReq(endpoint) {
  return axios.get(`/${sitekey}/${endpoint}`,
    { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
}

export function fetchStats() {
  const req = getReq('stats/api');

  return {
    type: GET_SITE_STATS,
    payload: req
  }
}

// -------------- AUTHORS -------------------
const authorReq = (authorID, type, req) => {
  const messageFromData = (data) => {
    if (typeof(data) === 'object' && data.messages) {
      return data.messages
    } else if (typeof(data) === 'string') {
      data.split('\n').slice(0, 3)
    } else {
      JSON.stringify(data)
    }
  };
  return req.then(res => {
    return {
      [ authorID ]: {
        [ type ]: res.data
      }
    }
  })
    .catch(err => {
      const message = messageFromData(err.response.data);
      return {
        [ authorID ]: {
          [ type ]: {
            status: err.response.statusText,
            error: message
          }
        }
      }
    })
};

export function fetchAuthorItems(authorID) {
  const req = authorReq(authorID, 'items', getReq(`/items/author/${authorID}`));
  console.log(req);
  return {
    type: GET_AUTHOR_ITEMS,
    payload: req
  }
}

// POSTS
export function importAuthor(authorID) {
  const req = authorReq(authorID, 'import',
    axios
      .post(`/${sitekey}/authors/import/${authorID}`,
        {},
        {
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
            'Content-Type': 'application/json',
          }
        }));

  return {
    type: IMPORT_AUTHOR,
    payload: req
  }
}