import axios from "axios";
import { sitekey } from "../config";

export const GET_SITE_STATS = "get_site_stats";

export const GET_AUTHOR_ITEMS = "get_author_items";
export const IMPORT_AUTHOR = "import_author";
export const CHECK_AUTHOR = "check_author";


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
  const messageFromData = (err) => {
    if (err.response) {
      const data = err.response.data;
      if (typeof (data) === 'object') {
        if (data.messages) {
          return data.messages;
        } else if (data.error) {
          return data.messages;
        }
      } else if (typeof (data) === 'string') {
        data.split('\n').slice(0, 3)
      } else {
        JSON.stringify(data)
      }
    } else {
      JSON.stringify(err)
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
      const message = messageFromData(err);
      return {
        [ authorID ]: {
          [ type ]: {
            status: err.response.statusText,
            messages: [ JSON.stringify(err) ],
            remote_host: err.request ? err.request.url : "unknown"
          }
        }
      }
    })
  }
;

export function fetchAuthorItems(authorID) {
  const req = authorReq(authorID, 'items', getReq(`items/author/${authorID}`));
  return {
    type: GET_AUTHOR_ITEMS,
    payload: req
  }
}

export function importAuthor(authorID) {
  const req = authorReq(authorID, 'import',
    axios
      .post(`/${sitekey}/authors/import/${authorID}`,
        {},
        {
          timeout: 5 * 60 * 1000, // 5 minutes
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

// Put check results into the same import object as import results
export function checkAuthor(authorID) {
  const req = authorReq(authorID, 'import',
    axios
      .get(`/${sitekey}/authors/check/${authorID}`,
        {
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
            'Content-Type': 'application/json',
          }
        }));

  return {
    type: CHECK_AUTHOR,
    payload: req
  }
}
