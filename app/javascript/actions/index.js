import axios from "axios";

export const GET_SITE_STATS = "get_site_stats";
export const GET_AUTHOR_ITEMS = "get_author_items";
export const IMPORT_AUTHOR = "import_author";


function getReq(rootPath, endpoint) {
  return axios.get(`${rootPath}/${endpoint}`,
    { headers: { 'X-Requested-With': 'XMLHttpRequest' } });
}

export function fetchStats(rootPath) {
  const req = getReq(rootPath, 'stats');

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
    console.log('res');
    console.log(res);
    return {
      [ authorID ]: {
        [ type ]: res.data
      }
    }
  })
    .catch(err => {
      console.log(err.response.data);
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


export function fetchAuthorItems(rootPath, authorID) {
  const req = authorReq(authorID, 'items', getReq(rootPath, `/items/author/${authorID}`));
  console.log(req);
  return {
    type: GET_AUTHOR_ITEMS,
    payload: req
  }
}

// POSTS
export function importAuthor(rootPath, authorID) {
  const req = authorReq(authorID, 'import',
    axios
      .post(`${rootPath}/authors/import/${authorID}`,
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